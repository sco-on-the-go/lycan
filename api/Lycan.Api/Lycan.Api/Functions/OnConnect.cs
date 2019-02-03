using System.Threading.Tasks;
using Amazon;
using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.DataModel;
using Amazon.Lambda.APIGatewayEvents;
using Amazon.Lambda.Core;
using Microsoft.Extensions.Logging;

namespace Lycan.Api
{
    public class OnConnect : BaseFunction
    {
        IDynamoDBContext DynamoContext { get; set; }

        public OnConnect() : this(new AmazonDynamoDBClient(), Configuration["GameTable"], Configuration["PlayerTable"])
        {
        }

        public OnConnect(IAmazonDynamoDB dynamoDBClient, string gameTableName, string playerTableName)
        {
            Logger.LogDebug($"OnConnect constructor with gameTableName: {gameTableName} and playerTableName: {playerTableName}");

            if (!string.IsNullOrEmpty(gameTableName))
                AWSConfigsDynamoDB.Context.TypeMappings[typeof(Game)] = new Amazon.Util.TypeMapping(typeof(Game), gameTableName);

            if (!string.IsNullOrEmpty(playerTableName))
                AWSConfigsDynamoDB.Context.TypeMappings[typeof(Player)] = new Amazon.Util.TypeMapping(typeof(Player), playerTableName);

            var config = new DynamoDBContextConfig { Conversion = DynamoDBEntryConversion.V2 };
            DynamoContext = new DynamoDBContext(dynamoDBClient, config);
        }

        public async Task<APIGatewayProxyResponse> InvokeAsync(APIGatewayProxyRequest request, ILambdaContext context)
        {
            var connectionId = "conn";// TODO: Enable this once its available in the library request.RequestContext.connectionId;

            Logger.LogDebug($"OnConnect.InvokeAsync with connectionId: {connectionId}");

            var newPlayer = new Player() { ConnectionId = connectionId };
            await DynamoContext.SaveAsync(newPlayer);

            return CreateSuccessResponse(newPlayer);
        }
    }
}
