using System.Collections.Generic;
using System.Net;
using Amazon.Lambda.APIGatewayEvents;
using Amazon.Lambda.Core;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

// Assembly attribute to enable the Lambda function's JSON input to be converted into a .NET class.
[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.Json.JsonSerializer))]

namespace Lycan.Api
{
    public abstract class BaseFunction
    {
        protected static ILogger Logger { get; set; }

        protected static IConfiguration Configuration { get; set; }

        static BaseFunction()
        {
            var builder = new ConfigurationBuilder().AddEnvironmentVariables();
            Configuration = builder.Build();

            var logfactory = new LoggerFactory();
            logfactory.AddLambdaLogger(Configuration.GetLambdaLoggerOptions());
            Logger = logfactory.CreateLogger("Logger");

            Logger.LogDebug($"BaseFunction static constructor");
        }

        public APIGatewayProxyResponse CreateSuccessResponse<T>(T responseObject)
        {
            return new APIGatewayProxyResponse {
                StatusCode = (int)HttpStatusCode.OK,
                Body = JsonConvert.SerializeObject(responseObject),
                Headers = new Dictionary<string, string> { { "Content-Type", "application/json" } }
            };
        }
    }
}
