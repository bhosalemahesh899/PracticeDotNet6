using System;
using System.Security.Cryptography;
using System.Text;

namespace Practice1
{
    public class JWTDecode1
    {
        public void Get()
        {
            var errorMessage = string.Empty;

            // Google RSA well known Public Key data is available at https://accounts.google.com/.well-known/openid-configuration by navigating to the path described in the "jwks_uri" parameter.
            // {
            //     e: "AQAB",        // RSA Exponent
            //     n: "ya_7gV....",  // RSA Modulus aka Well Known Public Key
            //     alg: "RS256"      // RSA Algorithm
            // }

            var verified = VerifyJWT_RS256_Signature(
                jwt: "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6Ik1haGVzaCBCaG9zYWxlIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMn0.BfsI-iXuyCpOJLfd2YSx4wvGIYBYAp-41oQceU07Ej8vfM26sRwikpPPYOg_RpnZAP2kYBB2chliZjp5TeGG8UNxLrjtwc6B8NkPTTSrDzMJsAn8fojVXbuo1zmdvlAAyWDP4RgR-73Q-2qTOzylG1B099qwdNqYS-RFGmTEfGVn0psP5hWlbue9KDkNlYjgzytQ8V7e2dbh_wv0jR3q6qYYUaE1viix34aI_qv3anLYGw-GeXML-SeQ2Q-DZQaXxvincL-9UJWy7XZzSA3DRbMigRhx4fk_5_PC-sC7jrTo2Jf6ZlX4xz6CtwyTmuRFWZEFuNZCZg04wcwXGeEhQA",
                publicKey: "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAu1SU1LfVLPHCozMxH2Mo4lgOEePzNm0tRgeLezV6ffAt0gunVTLw7onLRnrq0/IzW7yWR7QkrmBL7jTKEn5u+qKhbwKfBstIs+bMY2Zkp18gnTxKLxoS2tFczGkPLPgizskuemMghRniWaoLcyehkd3qqGElvW/VDL5AaWTg0nLVkjRo9z+40RQzuVaE8AkAFmxZzow3x+VJYKdjykkJ0iT9wCS0DRTXu269V264Vf/3jvredZiKRkgwlL9xNAwxXFg0x/XFw005UWVRIkdgcKWTjpBP2dPwVZ4WWC+9aGVd+Gyn1o0CLelf4rEjGoXbAAEgAqeGUxrcIlbjXfbcmwIDAQAB",
                exponent: "AQAB",
                errorMessage: out errorMessage);

            if (!verified)
            {
                // TODO: log error: 
                // TODO: Do something
            }
        }

        public static bool VerifyJWT_RS256_Signature(string jwt, string publicKey, string exponent, out string errorMessage)
        {
            if (string.IsNullOrEmpty(jwt))
            {
                errorMessage = "Error verifying JWT token signature: Javascript Web Token was null or empty.";
                return false;
            }

            var jwtArray = jwt.Split('.');
            if (jwtArray.Length != 3 && jwtArray.Length != 5)
            {
                errorMessage = "Error verifying JWT token signature: Javascript Web Token did not match expected format. Parts count was " + jwtArray.Length + " when it should have been 3 or 5.";
                return false;
            }

            if (string.IsNullOrEmpty(publicKey))
            {
                errorMessage = "Error verifying JWT token signature: Well known RSA Public Key modulus was null or empty.";
                return false;
            }

            if (string.IsNullOrEmpty(exponent))
            {
                errorMessage = "Error verifying JWT token signature: Well known RSA Public Key exponent was null or empty.";
                return false;
            }

            try
            {
                string publicKeyFixed = (publicKey.Length % 4 == 0 ? publicKey : publicKey + "====".Substring(publicKey.Length % 4)).Replace("_", "/").Replace("-", "+");
                var publicKeyBytes = Convert.FromBase64String(publicKeyFixed);

                var jwtSignatureFixed = (jwtArray[2].Length % 4 == 0 ? jwtArray[2] : jwtArray[2] + "====".Substring(jwtArray[2].Length % 4)).Replace("_", "/").Replace("-", "+");
                var jwtSignatureBytes = Convert.FromBase64String(jwtSignatureFixed);

                RSACryptoServiceProvider rsa = new RSACryptoServiceProvider();
                rsa.ImportParameters(
                    new RSAParameters()
                    {
                        Modulus = publicKeyBytes,
                        Exponent = Convert.FromBase64String(exponent)
                    }
                );

                SHA256 sha256 = SHA256.Create();
                byte[] hash = sha256.ComputeHash(Encoding.UTF8.GetBytes(jwtArray[0] + '.' + jwtArray[1]));

                RSAPKCS1SignatureDeformatter rsaDeformatter = new RSAPKCS1SignatureDeformatter(rsa);
                rsaDeformatter.SetHashAlgorithm("SHA256");
                if (!rsaDeformatter.VerifySignature(hash, jwtSignatureBytes))
                {
                    errorMessage = "Error verifying JWT token signature: hash did not match expected value.";
                    return false;
                }
            }
            catch (Exception ex)
            {
                errorMessage = "Error verifying JWT token signature: " + ex.Message;
                return false;
                //throw ex;
            }

            errorMessage = string.Empty;
            return true;
        }
    }
}
