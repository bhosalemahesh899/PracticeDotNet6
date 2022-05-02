namespace QBank1Q2
{
    class Program
    {
        public void Main(string[] args)
        {
            ClassA classA = new ClassA();
            ClassA.WriteLog("Hello!!");
            classA.ReadLog();
        }

    }

    static class ClassA
    {
        public static string strLog;
        public static void WriteLog(string str)
        {
            strLog = str;
        }
        public string ReadLog(string strLog)
        {
            string str = strLog;
        }
    }
}
