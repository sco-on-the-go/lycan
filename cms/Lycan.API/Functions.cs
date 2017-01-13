using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading.Tasks;

using Amazon.Lambda.Core;
using Amazon.Lambda.APIGatewayEvents;

using Amazon;
using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.DataModel;

using Newtonsoft.Json;

// Assembly attribute to enable the Lambda function's JSON input to be converted into a .NET class.
[assembly: LambdaSerializerAttribute(typeof(Amazon.Lambda.Serialization.Json.JsonSerializer))]

namespace Lycan.API
{
    public class Functions
    {
        // This const is the name of the environment variable that the serverless.template will use to set
        // the name of the DynamoDB table used to store blog posts.
        const string TABLENAME_ENVIRONMENT_VARIABLE_LOOKUP = "BlogTable";

        public const string ID_QUERY_STRING_NAME = "Id";
        IDynamoDBContext DDBContext { get; set; }

        /// <summary>
        /// Default constructor that Lambda will invoke.
        /// </summary>
        public Functions()
        {
            // Check to see if a table name was passed in through environment variables and if so 
            // add the table mapping.
            var tableName = System.Environment.GetEnvironmentVariable(TABLENAME_ENVIRONMENT_VARIABLE_LOOKUP);
            if(!string.IsNullOrEmpty(tableName))
            {
                AWSConfigsDynamoDB.Context.TypeMappings[typeof(Blog)] = new Amazon.Util.TypeMapping(typeof(Blog), tableName);
            }

            var config = new DynamoDBContextConfig { Conversion = DynamoDBEntryConversion.V2 };
            this.DDBContext = new DynamoDBContext(new AmazonDynamoDBClient(), config);
        }

        /// <summary>
        /// Constructor used for testing passing in a preconfigured DynamoDB client.
        /// </summary>
        /// <param name="ddbClient"></param>
        /// <param name="tableName"></param>
        public Functions(IAmazonDynamoDB ddbClient, string tableName)
        {
            if (!string.IsNullOrEmpty(tableName))
            {
                AWSConfigsDynamoDB.Context.TypeMappings[typeof(Blog)] = new Amazon.Util.TypeMapping(typeof(Blog), tableName);
            }

            var config = new DynamoDBContextConfig { Conversion = DynamoDBEntryConversion.V2 };
            this.DDBContext = new DynamoDBContext(ddbClient, config);
        }
        
        public APIGatewayProxyResponse GetAsync(APIGatewayProxyRequest request, ILambdaContext context)
        {
            Random r = new Random();

            int value = r.Next(0, 101);
            string action;

            if (value >= 30)
            {
                action = "Empty";
            }
            else if (value >= 15)
            {
                action = "Obstacle";
            }
            else if (value >= 5)
            {
                action = "Bad guy";
            }
            else
            {
                action = "Good guy";
            }

            var response = new APIGatewayProxyResponse
            {
                StatusCode = (int)HttpStatusCode.OK,
                Body = JsonConvert.SerializeObject(action),
                Headers = new Dictionary<string, string> { { "Content-Type", "application/json" } }
            };
            return response;
        }

        /// <summary>
        /// A Lambda function that adds a blog post.
        /// </summary>
        /// <param name="request"></param>
        /// <returns></returns>
        public async Task<APIGatewayProxyResponse> PostAsync(APIGatewayProxyRequest request, ILambdaContext context)
        {
            var blog = JsonConvert.DeserializeObject<Blog>(request?.Body);
            blog.Id = Guid.NewGuid().ToString();
            blog.CreatedTimestamp = DateTime.Now;

            context.Logger.LogLine($"Saving blog with id {blog.Id}");
            await DDBContext.SaveAsync<Blog>(blog);

            var response = new APIGatewayProxyResponse
            {
                StatusCode = (int)HttpStatusCode.OK,
                Body = JsonConvert.SerializeObject(blog),
                Headers = new Dictionary<string, string> { { "Content-Type", "application/json" } }
            };
            return response;
        }
        //AKIAJ4QFGEFSCMINKV7A
        //ZQRqn+rPZrpncJisFwcZqtr5chViM1Aay4HOv49r
    }
}
