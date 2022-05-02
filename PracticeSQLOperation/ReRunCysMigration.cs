using Microsoft.Data.SqlClient;
using Microsoft.SqlServer.Management.Common;
using Microsoft.SqlServer.Management.Smo;
using System;
using System.Collections.Generic;
//using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PracticeSQLOperation;

internal class ReRunCysMigration
{
    private const string ConnectionString = "Data Source=(local);Initial Catalog={0};Integrated Security=true";

    public static void ExecuteQuery()
    {
        var dbName = $"Temp_{DateTime.Now.ToString("yyyy_MM_dd_HH_mm_ss")}";
        try
        {
            RunWithOutTran($"CREATE DATABASE {dbName}");
            RunMigration(dbName);
            //RunMigration(dbName);
        }
        catch (Exception ex)
        {
            //Run($"DROP DATABASE {dbName}");
            Console.WriteLine(ex);
        }

    }

    private static void RunMigration(string dbName)
    {
        for (int i = 1; i <= 39; i++)
        {
            using (var sr = new StreamReader($@"D:\Projects\CYS\Code\HotFix\CFM\CFM.Core\Scripts\{i}.sql"))
            {
                var text = sr.ReadToEnd();
                Run(text, dbName);
            }
        }
    }

    private static void Run(string query, string dbName = null)
    {
        var db = dbName ?? "master";
        using (SqlConnection connection = new SqlConnection(string.Format(ConnectionString, db)))
        {
            Server server = new Server(new ServerConnection(connection));
            server.ConnectionContext.BeginTransaction();
            try
            {
                server.ConnectionContext.ExecuteNonQuery(query);
                server.ConnectionContext.CommitTransaction();
            }
            catch (Exception ex)
            {
                server.ConnectionContext.RollBackTransaction();
                throw;
            }
        }
    }

    private static void RunWithOutTran(string query, string dbName = null)
    {
        var db = dbName ?? "master";
        using (SqlConnection connection = new SqlConnection(string.Format(ConnectionString, db)))
        {
            Server server = new Server(new ServerConnection(connection));
            server.ConnectionContext.ExecuteNonQuery(query);
        }
    }
}
