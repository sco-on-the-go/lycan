using Amazon;
using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.DataModel;
using Amazon.Lambda.APIGatewayEvents;
using Amazon.Lambda.Core;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading.Tasks;

// Assembly attribute to enable the Lambda function's JSON input to be converted into a .NET class.
[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.Json.JsonSerializer))]

namespace Lycan.Api
{
    public class Functions
    {
        IDynamoDBContext DynamoContext { get; set; }

        /// <summary>
        /// Default constructor that Lambda will invoke.
        /// </summary>
        public Functions()
        {
            var gameTableName = Environment.GetEnvironmentVariable("GameTable");
            if (!string.IsNullOrEmpty(gameTableName))
                AWSConfigsDynamoDB.Context.TypeMappings[typeof(Game)] = new Amazon.Util.TypeMapping(typeof(Game), gameTableName);

            var playerTableName = Environment.GetEnvironmentVariable("PlayerTable");
            if (!string.IsNullOrEmpty(playerTableName))
                AWSConfigsDynamoDB.Context.TypeMappings[typeof(Player)] = new Amazon.Util.TypeMapping(typeof(Player), playerTableName);

            var config = new DynamoDBContextConfig { Conversion = DynamoDBEntryConversion.V2 };
            DynamoContext = new DynamoDBContext(new AmazonDynamoDBClient(), config);
        }

        /// <summary>
        /// Constructor used for testing passing in a preconfigured DynamoDB client.
        /// </summary>
        /// <param name="ddbClient"></param>
        /// <param name="tableName"></param>
        public Functions(IAmazonDynamoDB ddbClient, string gameTableName, string playerTableName)
        {
            if (!string.IsNullOrEmpty(gameTableName))
                AWSConfigsDynamoDB.Context.TypeMappings[typeof(Game)] = new Amazon.Util.TypeMapping(typeof(Game), gameTableName);

            if (!string.IsNullOrEmpty(playerTableName))
                AWSConfigsDynamoDB.Context.TypeMappings[typeof(Player)] = new Amazon.Util.TypeMapping(typeof(Player), playerTableName);

            var config = new DynamoDBContextConfig { Conversion = DynamoDBEntryConversion.V2 };
            DynamoContext = new DynamoDBContext(ddbClient, config);
        }

        /// <summary>
        /// A Lambda function that returns back a page worth of blog posts.
        /// </summary>
        /// <param name="request"></param>
        /// <returns>The list of blogs</returns>
        public async Task<APIGatewayProxyResponse> GetBlogsAsync(APIGatewayProxyRequest request, ILambdaContext context)
        {
            context.Logger.LogLine("Getting blogs");
            var search = DynamoContext.ScanAsync<Blog>(null);
            var page = await search.GetNextSetAsync();
            context.Logger.LogLine($"Found {page.Count} blogs");

            var response = new APIGatewayProxyResponse
            {
                StatusCode = (int)HttpStatusCode.OK,
                Body = JsonConvert.SerializeObject(page),
                Headers = new Dictionary<string, string> { { "Content-Type", "application/json" } }
            };

            return response;
        }
    }
}
