using System;

namespace QBank1Q2
{
    class Program
    {
        static void Main(string[] args)
        {
            ABC abc = new ABC();
            Console.WriteLine(abc.strABC);
            abc.cnt = 10;
            Console.WriteLine(abc.showCount(10));
        }
    }

    public class ABC
{
	public const string strABC = string.Empty();
    public ABC()
    {
        strABC = "ABC";
    }
    int cnt { get; set; }
    public string showCount(int cnt)
    {
        string strCnt = (String)cnt;
        return strCnt;
    }
}


}
