using System;

namespace QBank1Q2
{
    class Program
    {
        static void Main(string[] args)
        {
            string strMessage = "ABC";
            strMessage = String.Concat(strMessage, "XYZ");
            int i = 0;
            while (i < 10)
            {
                if (i % 2 == 0)
                {
                    strMessage = String.Concat(strMessage, i.ToString());
                }
                if (i == 7) break;

                i += 1;
            }
            Console.WriteLine(strMessage);
        }

    }
}
