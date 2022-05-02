using Microsoft.Data.SqlClient;
using Microsoft.SqlServer.Management.Common;
using Microsoft.SqlServer.Management.Smo;
using System;
using System.IO;

namespace PracticeFileOperations
{
    public class CysReRunMigration
    {
        public static void ExecuteQuery()
        {
            using (SqlConnection connection = new SqlConnection("Server=LAPTOP-C8LOE0F5;Initial Catalog=master;Integrated Security=true;MultipleActiveResultSets=False;Encrypt=True;Connection Timeout=30;"))
            {
                Server server = new Server(new ServerConnection(connection));
                server.ConnectionContext.ExecuteNonQuery("Create Database T2");

                for (int i = 0; i < 2; i++)
                {
                    using (var sr = new StreamReader($@"D:\Projects\CYS\Code\Server2\CFM\CFM.Core\Scripts\{i}.sql"))
                    {
                        var text = sr.ReadToEnd();
                        try
                        {
                            server.ConnectionContext.ExecuteNonQuery(text);
                        }
                        catch (Exception e)
                        {
                            Console.WriteLine(e);
                        }
                    }
                }
            }
        }
    }
}
