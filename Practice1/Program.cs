using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.IO;
using System.Linq;

namespace Practice1
{
    class Program
    {
        static void Main(string[] args)
        {
            //JsonTextReader reader = new JsonTextReader(new StringReader(@"{'CPU':'01/23/1992'"));
            //var a = reader.Read();
            //Console.WriteLine(reader.Value);
            //var b = reader.Read();
            //Console.WriteLine(reader.Value);
            //var dt = reader.ReadAsDateTime();
            //Console.WriteLine(reader.Value);

            using StringReader stringReader = new StringReader(@"'01/23/1992'");
            using JsonTextReader reader = new JsonTextReader(stringReader);
            var dt = reader.ReadAsDateTime();
            Console.WriteLine(reader.Value);

            Console.WriteLine("Hello World!");

            GetTokenInfo("eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6Ik1haGVzaCBCaG9zYWxlIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMn0.BfsI-iXuyCpOJLfd2YSx4wvGIYBYAp-41oQceU07Ej8vfM26sRwikpPPYOg_RpnZAP2kYBB2chliZjp5TeGG8UNxLrjtwc6B8NkPTTSrDzMJsAn8fojVXbuo1zmdvlAAyWDP4RgR-73Q-2qTOzylG1B099qwdNqYS-RFGmTEfGVn0psP5hWlbue9KDkNlYjgzytQ8V7e2dbh_wv0jR3q6qYYUaE1viix34aI_qv3anLYGw-GeXML-SeQ2Q-DZQaXxvincL-9UJWy7XZzSA3DRbMigRhx4fk_5_PC-sC7jrTo2Jf6ZlX4xz6CtwyTmuRFWZEFuNZCZg04wcwXGeEhQA");

            new JWTDecode1().Get();
            new JWTDecode2().Get();
            new JWTDecode3().Get();
        }

        public static Dictionary<string, string> GetTokenInfo(string token)
        {
            var TokenInfo = new Dictionary<string, string>();

            var handler = new JwtSecurityTokenHandler();
            var jwtSecurityToken = handler.ReadJwtToken(token);
            var claims = jwtSecurityToken.Claims.ToList();

            foreach (var claim in claims)
            {
                TokenInfo.Add(claim.Type, claim.Value);
            }

            return TokenInfo;
        }
    }
}
