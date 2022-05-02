using System.IO;
using System.Linq;

namespace PracticeFileOperations
{
    public static class EditTextFiles
    {
        public static void Script2()
        {
            using (var sr = new StreamReader(@"D:\Projects\CYS\Code\Server2\CFM\CFM.Core\Scripts\2.sql"))
            {
                // Read the stream as a string, and write the string to the console.
                var text = sr.ReadToEnd();
                var updatedText = "";
                var arr = text.Split("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
                var i = 0;
                foreach (var item in arr)
                {
                    var itemVal = item;
                    if (i == 0)
                    {
                        updatedText = itemVal;
                        i++;
                        continue;
                    }
                    if (itemVal.Contains("ADD CONSTRAINT") || item.Contains("ALTER TABLE"))
                    {
                        var splitedItem = itemVal.Split("ADD CONSTRAINT [");
                        var word = splitedItem.Skip(1).FirstOrDefault();
                        var bracketIndex = word.IndexOf("]");
                        var ww = word.Substring(0, bracketIndex);
                        itemVal = itemVal.Insert(0, ww);
                    }
                    updatedText += itemVal;
                    i++;
                }
            }
        }

        public static void Change1()
        {
            using (var sr = new StreamReader(@"D:\Projects\CYS\Code\Server2\CFM\CFM.Core\Scripts\2.sql"))
            {
                // Read the stream as a string, and write the string to the console.
                var text = sr.ReadToEnd();
                var updatedText = "";
                var arr = text.Split("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
                var i = 0;
                foreach (var item in arr)
                {
                    var itemVal = item;
                    if (i == 0)
                    {
                        updatedText = itemVal;
                        i++;
                        continue;
                    }
                    if (itemVal.Contains("CREATE TABLE") || item.Contains("ALTER TABLE"))
                    {
                        var splitedItem = itemVal.Split("[dbo].[");
                        var word = splitedItem.Skip(1).FirstOrDefault();
                        var bracketIndex = word.IndexOf("]");
                        var ww = word.Substring(0, bracketIndex);
                        itemVal = itemVal.Insert(0, ww);
                    }
                    updatedText += itemVal;
                    i++;
                }
            }
        }

        public static void Change2()
        {
            using (var sr = new StreamReader(@"D:\Projects\CYS\Code\Server2\CFM\CFM.Core\Scripts\2.sql"))
            {
                // Read the stream as a string, and write the string to the console.
                var text = sr.ReadToEnd();
                var updatedText = "";
                var arr = text.Split("BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB");
                var i = 0;
                foreach (var item in arr)
                {
                    var itemVal = item;
                    if (i == 0)
                    {
                        updatedText = itemVal;
                        i++;
                        continue;
                    }
                    if (itemVal.Contains("ADD CONSTRAINT") && item.Contains("ALTER TABLE"))
                    {
                        var splitedItem = itemVal.Split("ADD CONSTRAINT [");
                        var word = splitedItem.Skip(1).FirstOrDefault();
                        var bracketIndex = word.IndexOf("]");
                        var ww = word.Substring(0, bracketIndex);
                        itemVal = itemVal.Insert(0, ww);
                    }

                    if (itemVal.Contains("DROP CONSTRAINT") && item.Contains("ALTER TABLE"))
                    {
                        var splitedItem = itemVal.Split("DROP CONSTRAINT [");
                        var word = splitedItem.Skip(1).FirstOrDefault();
                        var bracketIndex = word.IndexOf("]");
                        var ww = word.Substring(0, bracketIndex);
                        itemVal = itemVal.Insert(0, ww);
                    }

                    updatedText += itemVal;
                    i++;
                }
            }
        }
    }
}