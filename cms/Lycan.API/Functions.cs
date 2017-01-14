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
        IDynamoDBContext DDBContext { get; set; }

        /// <summary>
        /// Default constructor that Lambda will invoke.
        /// </summary>
        public Functions()
        {
            var config = new DynamoDBContextConfig { Conversion = DynamoDBEntryConversion.V2 };
            this.DDBContext = new DynamoDBContext(new AmazonDynamoDBClient(), config);
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

        public async Task<APIGatewayProxyResponse> HostGameAsync(APIGatewayProxyRequest request, ILambdaContext context)
        {
            var requestBody = JsonConvert.DeserializeObject<HostGameRequest>(request?.Body);

            Game game = new Game() { GameId = Guid.NewGuid(), Name = requestBody.GameName, State = GameStateEnum.Lobby };

            context.Logger.LogLine($"{requestBody.GameName} has been created as a new game");
            await DDBContext.SaveAsync(game);
            
            // Add the three table down cards
            Player card1 = new Player() { PlayerId = Guid.NewGuid(), GameId = game.GameId, Name = "Table Down 1", IsReady = true, IsNPC = true };
            await DDBContext.SaveAsync(card1);
            Player card2 = new Player() { PlayerId = Guid.NewGuid(), GameId = game.GameId, Name = "Table Down 2", IsReady = true, IsNPC = true };
            await DDBContext.SaveAsync(card2);
            Player card3 = new Player() { PlayerId = Guid.NewGuid(), GameId = game.GameId, Name = "Table Down 3", IsReady = true, IsNPC = true };
            await DDBContext.SaveAsync(card3);

            Player player = new Player() { PlayerId = Guid.NewGuid(), GameId = game.GameId, Name = requestBody.PlayerName, IsReady = false };
            await DDBContext.SaveAsync(player);

            return new APIGatewayProxyResponse
            {
                StatusCode = (int)HttpStatusCode.OK,
                Body = JsonConvert.SerializeObject(new HostGameResponse()
                {
                    GameId = game.GameId,
                    PlayerId = player.PlayerId
                }),
                Headers = new Dictionary<string, string> { { "Content-Type", "application/json" } }
            };
        }

        public async Task<APIGatewayProxyResponse> JoinGameAsync(APIGatewayProxyRequest request, ILambdaContext context)
        {
            var requestBody = JsonConvert.DeserializeObject<JoinGameRequest>(request?.Body);

            var gameScanResult = DDBContext.ScanAsync<Game>(new[] { new ScanCondition("Name", Amazon.DynamoDBv2.DocumentModel.ScanOperator.Equal, requestBody.GameName) });
            var games = await gameScanResult.GetRemainingAsync();
            
            if (games == null || games.Count == 0)
                throw new Exception($"{requestBody.GameName} was not found");

            var game = games.FirstOrDefault();

            Player player = new Player() { PlayerId = Guid.NewGuid(), GameId = game.GameId, Name = requestBody.PlayerName, IsReady = false, IsNPC = false };

            context.Logger.LogLine($"{requestBody.PlayerName} joined the game {game.GameId}");
            await DDBContext.SaveAsync(player);

            return new APIGatewayProxyResponse
            {
                StatusCode = (int)HttpStatusCode.OK,
                Body = JsonConvert.SerializeObject(new JoinGameResponse()
                {
                    GameId = game.GameId,
                    PlayerId = player.PlayerId
                }),
                Headers = new Dictionary<string, string> { { "Content-Type", "application/json" } }
            };
        }

        public async Task<APIGatewayProxyResponse> IsReadyAsync(APIGatewayProxyRequest request, ILambdaContext context)
        {
            var requestBody = JsonConvert.DeserializeObject<IsReadyRequest>(request?.Body);

            Player player = await DDBContext.LoadAsync<Player>(requestBody.PlayerId);
            if (player == null)
                throw new Exception($"{requestBody.PlayerId} was not found");

            player.IsReady = true;
            await DDBContext.SaveAsync(player);
            
            var scanResult = DDBContext.ScanAsync<Player>(new[] { new ScanCondition("GameId", Amazon.DynamoDBv2.DocumentModel.ScanOperator.Equal, player.GameId) });
            var players = await scanResult.GetRemainingAsync();

            context.Logger.LogLine($"{players.Count(p => p.IsReady)} Ready : {players.Count(p => !p.IsReady)} Not Ready");

            Game game = await DDBContext.LoadAsync<Game>(player.GameId);
            if (game == null)
                throw new Exception($"{player.GameId} was not found");

            if (players.All(p => p.IsReady == true))
            {
                List<PlayerTypeEnum> types = new List<API.PlayerTypeEnum>()
                {
                    PlayerTypeEnum.Werewolf,
                    PlayerTypeEnum.Werewolf,
                    PlayerTypeEnum.Robber,
                    PlayerTypeEnum.Troublemaker,
                    PlayerTypeEnum.Seer
                };
                
                foreach (Player gamePlayer in players.OrderBy(x => Guid.NewGuid()))
                {
                    if (types.Any())
                    {
                        gamePlayer.PlayerType = types[0];
                        types.RemoveAt(0);
                    }
                    else
                        gamePlayer.PlayerType = PlayerTypeEnum.Villager;

                    if (player.PlayerId == gamePlayer.PlayerId)
                        player.PlayerType = gamePlayer.PlayerType;

                    await DDBContext.SaveAsync(gamePlayer);
                }

                game.State = GameStateEnum.Ready;
                await DDBContext.SaveAsync(game);
            }

            return new APIGatewayProxyResponse
            {
                StatusCode = (int)HttpStatusCode.OK,
                Body = JsonConvert.SerializeObject(new IsReadyResponse()
                {
                    Players = players.Select(p => new IsReadyResponse.PlayerViewModel { PlayerId = p.PlayerId, Name = p.Name, IsReady = p.IsReady, PlayerType = p.PlayerType, IsNPC = p.IsNPC }).ToList(),
                    GameState = game.State,
                    PlayerType = player.PlayerType
                }),
                Headers = new Dictionary<string, string> { { "Content-Type", "application/json" } }
            };
        }

        public async Task<APIGatewayProxyResponse> VoteAsync(APIGatewayProxyRequest request, ILambdaContext context)
        {
            var requestBody = JsonConvert.DeserializeObject<IsReadyRequest>(request?.Body);

            Player player = await DDBContext.LoadAsync<Player>(requestBody.PlayerId);
            if (player == null)
                throw new Exception($"{requestBody.PlayerId} was not found");

            player.IsReady = true;
            await DDBContext.SaveAsync(player);

            var scanResult = DDBContext.ScanAsync<Player>(new[] { new ScanCondition("GameId", Amazon.DynamoDBv2.DocumentModel.ScanOperator.Equal, player.GameId) });
            var players = await scanResult.GetRemainingAsync();

            context.Logger.LogLine($"{players.Count(p => p.IsReady)} Ready : {players.Count(p => !p.IsReady)} Not Ready");

            Game game = await DDBContext.LoadAsync<Game>(player.GameId);
            if (game == null)
                throw new Exception($"{player.GameId} was not found");
            
            return new APIGatewayProxyResponse
            {
                StatusCode = (int)HttpStatusCode.OK,
                Body = JsonConvert.SerializeObject(new IsReadyResponse()
                {
                    Players = players.Select(p => new IsReadyResponse.PlayerViewModel { PlayerId = p.PlayerId, Name = p.Name, IsReady = p.IsReady, PlayerType = p.PlayerType, IsNPC = p.IsNPC }).ToList(),
                    GameState = game.State,
                    PlayerType = player.PlayerType
                }),
                Headers = new Dictionary<string, string> { { "Content-Type", "application/json" } }
            };
        }

        public class HostGameRequest
        {
            public string GameName { get; set; }
            public string PlayerName { get; set; }
        }

        public class HostGameResponse
        {
            public Guid GameId { get; set; }
            public Guid PlayerId { get; set; }
        }

        public class JoinGameRequest
        {
            public string GameName { get; set; }
            public string PlayerName { get; set; }
        }

        public class JoinGameResponse
        {
            public Guid GameId { get; set; }
            public Guid PlayerId { get; set; }
        }

        public class IsReadyRequest
        {
            public Guid PlayerId { get; set; }
        }

        public class IsReadyResponse
        {
            public List<PlayerViewModel> Players { get; set; }
            public GameStateEnum GameState { get; set; }
            public PlayerTypeEnum PlayerType { get; set; }

            public class PlayerViewModel
            {
                public Guid PlayerId { get; set; }
                public string Name { get; set; }
                public bool IsReady { get; set; }
                public bool IsNPC { get; set; }
                public PlayerTypeEnum PlayerType { get; set; }
            }
        }

    }
}
