using JWT;
using JWT.Algorithms;
using JWT.Builder;
using JWT.Exceptions;
using System.Collections.Generic;
using System.Security.Cryptography;

namespace Practice1
{
    public class JWTDecode2
    {
        public void Get()
        {
            string jwt = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6Ik1haGVzaCBCaG9zYWxlIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMn0.BfsI-iXuyCpOJLfd2YSx4wvGIYBYAp-41oQceU07Ej8vfM26sRwikpPPYOg_RpnZAP2kYBB2chliZjp5TeGG8UNxLrjtwc6B8NkPTTSrDzMJsAn8fojVXbuo1zmdvlAAyWDP4RgR-73Q-2qTOzylG1B099qwdNqYS-RFGmTEfGVn0psP5hWlbue9KDkNlYjgzytQ8V7e2dbh_wv0jR3q6qYYUaE1viix34aI_qv3anLYGw-GeXML-SeQ2Q-DZQaXxvincL-9UJWy7XZzSA3DRbMigRhx4fk_5_PC-sC7jrTo2Jf6ZlX4xz6CtwyTmuRFWZEFuNZCZg04wcwXGeEhQA";
            string modulus = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAu1SU1LfVLPHCozMxH2Mo4lgOEePzNm0tRgeLezV6ffAt0gunVTLw7onLRnrq0/IzW7yWR7QkrmBL7jTKEn5u+qKhbwKfBstIs+bMY2Zkp18gnTxKLxoS2tFczGkPLPgizskuemMghRniWaoLcyehkd3qqGElvW/VDL5AaWTg0nLVkjRo9z+40RQzuVaE8AkAFmxZzow3x+VJYKdjykkJ0iT9wCS0DRTXu269V264Vf/3jvredZiKRkgwlL9xNAwxXFg0x/XFw005UWVRIkdgcKWTjpBP2dPwVZ4WWC+9aGVd+Gyn1o0CLelf4rEjGoXbAAEgAqeGUxrcIlbjXfbcmwIDAQAB";
            string exponent = "AQAB";

            try
            {
                IDictionary<string, object> claims = Decode(jwt, modulus, exponent);
            }
            catch (SignatureVerificationException ex)
            {
                var ss = ex;
                // signature invalid, handle it here
            }
        }

        private IDictionary<string, object> Decode(string token, string modulus, string exponent)
        {
            var urlEncoder = new JwtBase64UrlEncoder();

            var rsaKey = RSA.Create();
            rsaKey.ImportParameters(new RSAParameters()
            {
                Modulus = urlEncoder.Decode(modulus),
                Exponent = urlEncoder.Decode(exponent)
            });

            var claims = new JwtBuilder()
                .WithAlgorithm(new RS256Algorithm(rsaKey))
                .MustVerifySignature()
                .Decode<IDictionary<string, object>>(token);

            return claims;
        }
    }
}
