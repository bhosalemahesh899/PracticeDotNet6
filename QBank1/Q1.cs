using System;

namespace QBank1
{
    class Q1
    {
        static void Main(string[] args)
        {
            Narendra narendra = new Narendra();
            Console.WriteLine(narendra.GetIntro());
            Console.WriteLine(narendra.GetHobby());

            Console.Read();
        }
    }

    public class Man
    {
        public virtual string GetIntro()
        {
            return "I am a man";
        }

        public virtual string GetHobby()
        {
            return "I love reading";
        }
    }

    public class Narendra : Man
    {
        public override string GetIntro()
        {
            return "I am Narendra";
        }
        public new string GetHobby()
        {
            return "I love singing";
        }
    }
}
