namespace QBank1Q2
{
    class Program
    {
        static void Main(string[] args)
        {
            Person person = new Person();
            person.GetCount("25");
            person.GetSalary(25000);
        }
    }

    public class Person
    {
        public int GetCount();
        public string GetSalary();
    }
}
