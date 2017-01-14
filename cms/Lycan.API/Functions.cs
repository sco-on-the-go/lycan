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
            player.GeneratePlayerColour();

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
            player.GeneratePlayerColour();

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

            if (player.IsReady != requestBody.IsReady)
            {
                player.IsReady = requestBody.IsReady;
                await DDBContext.SaveAsync(player);
            }
            var scanResult = DDBContext.ScanAsync<Player>(new[] { new ScanCondition("GameId", Amazon.DynamoDBv2.DocumentModel.ScanOperator.Equal, player.GameId) });
            var players = await scanResult.GetRemainingAsync();

            context.Logger.LogLine($"{players.Count(p => p.IsReady)} Ready : {players.Count(p => !p.IsReady)} Not Ready");

            Game game = await DDBContext.LoadAsync<Game>(player.GameId);
            if (game == null)
                throw new Exception($"{player.GameId} was not found");

            if (players.All(p => p.IsReady == true) && game.State == GameStateEnum.Lobby)
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

                game.State = GameStateEnum.InGame;
                game.CurrentPlayerId = GetNextPlayer(players, game.CurrentPlayerId);
                await DDBContext.SaveAsync(game);
            }

            return new APIGatewayProxyResponse
            {
                StatusCode = (int)HttpStatusCode.OK,
                Body = JsonConvert.SerializeObject(new IsReadyResponse()
                {
                    Players = players.Select(p => new PlayerViewModel { PlayerId = p.PlayerId, Name = p.Name, IsReady = p.IsReady, PlayerType = p.PlayerType, IsNPC = p.IsNPC, VoteForPlayerId = p.VoteForPlayerId, ColourBrightness = p.ColourBrightness, ColourHue = p.ColourHue, ColourSaturation = p.ColourSaturation }).ToList(),
                    GameState = game.State,
                    PlayerType = player.PlayerType,
                    CurrentPlayerId = game.CurrentPlayerId
                }),
                Headers = new Dictionary<string, string> { { "Content-Type", "application/json" } }
            };
        }

        private Guid GetNextPlayer(List<Player> players, Guid currentPlayerId)
        {
            PlayerTypeEnum currentPlayerType = 0;
            if (currentPlayerId != Guid.Empty)
                currentPlayerType = players.FirstOrDefault(p => p.PlayerId == currentPlayerId).PlayerType;
            
            if (currentPlayerType < PlayerTypeEnum.Seer && players.Any(p => p.PlayerType == PlayerTypeEnum.Seer && !p.IsNPC))
                return players.First(p => p.PlayerType == PlayerTypeEnum.Seer).PlayerId;
            else if (currentPlayerType < PlayerTypeEnum.Robber && players.Any(p => p.PlayerType == PlayerTypeEnum.Robber && !p.IsNPC))
                return players.First(p => p.PlayerType == PlayerTypeEnum.Robber).PlayerId;
            else if (currentPlayerType < PlayerTypeEnum.Troublemaker && players.Any(p => p.PlayerType == PlayerTypeEnum.Troublemaker && !p.IsNPC))
                return players.First(p => p.PlayerType == PlayerTypeEnum.Troublemaker).PlayerId;
            else
                return Guid.Empty;
        }

        public async Task<APIGatewayProxyResponse> PlayerTurnAsync(APIGatewayProxyRequest request, ILambdaContext context)
        {
            var requestBody = JsonConvert.DeserializeObject<PlayerTurnRequest>(request?.Body);

            Player player = await DDBContext.LoadAsync<Player>(requestBody.PlayerId);
            if (player == null)
                throw new Exception($"{requestBody.PlayerId} was not found");
            
            var scanResult = DDBContext.ScanAsync<Player>(new[] { new ScanCondition("GameId", Amazon.DynamoDBv2.DocumentModel.ScanOperator.Equal, player.GameId) });
            var players = await scanResult.GetRemainingAsync();

            Game game = await DDBContext.LoadAsync<Game>(player.GameId);
            if (game == null)
                throw new Exception($"{player.GameId} was not found");

            if (game.CurrentPlayerId == requestBody.PlayerId)
            {
                game.CurrentPlayerId = GetNextPlayer(players, game.CurrentPlayerId);

                if (game.CurrentPlayerId == Guid.Empty)
                    game.State = GameStateEnum.Vote;

                await DDBContext.SaveAsync(game);

                if (requestBody.RobbedPlayerId != Guid.Empty)
                {
                    var robbedPlayer = players.FirstOrDefault(p => p.PlayerId == requestBody.RobbedPlayerId);

                    if (robbedPlayer != null)
                    {
                        PlayerTypeEnum oldRobbedPlayerType = robbedPlayer.PlayerType;
                        robbedPlayer.PlayerType = player.PlayerType;
                        player.PlayerType = oldRobbedPlayerType;
                        await DDBContext.SaveAsync(robbedPlayer);
                        await DDBContext.SaveAsync(player);
                    }
                }

                if (requestBody.TroubledPlayerId1 != Guid.Empty && requestBody.TroubledPlayerId1 != Guid.Empty)
                {
                    var troublePlayer1 = players.FirstOrDefault(p => p.PlayerId == requestBody.TroubledPlayerId1);
                    var troublePlayer2 = players.FirstOrDefault(p => p.PlayerId == requestBody.TroubledPlayerId2);

                    if (troublePlayer1 != null && troublePlayer2 != null)
                    {
                        PlayerTypeEnum oldPlayer1Type = troublePlayer1.PlayerType;
                        troublePlayer1.PlayerType = troublePlayer2.PlayerType;
                        troublePlayer2.PlayerType = oldPlayer1Type;
                        await DDBContext.SaveAsync(troublePlayer1);
                        await DDBContext.SaveAsync(troublePlayer2);
                    }
                }
            }

            return new APIGatewayProxyResponse
            {
                StatusCode = (int)HttpStatusCode.OK,
                Body = JsonConvert.SerializeObject(new IsReadyResponse()
                {
                    Players = players.Select(p => new PlayerViewModel { PlayerId = p.PlayerId, Name = p.Name, IsReady = p.IsReady, PlayerType = p.PlayerType, IsNPC = p.IsNPC, VoteForPlayerId = p.VoteForPlayerId, ColourBrightness = p.ColourBrightness, ColourHue = p.ColourHue, ColourSaturation = p.ColourSaturation }).ToList(),
                    GameState = game.State,
                    PlayerType = player.PlayerType,
                    CurrentPlayerId = game.CurrentPlayerId
                }),
                Headers = new Dictionary<string, string> { { "Content-Type", "application/json" } }
            };
        }

        public async Task<APIGatewayProxyResponse> VoteAsync(APIGatewayProxyRequest request, ILambdaContext context)
        {
            var requestBody = JsonConvert.DeserializeObject<VoteRequest>(request?.Body);

            Player player = await DDBContext.LoadAsync<Player>(requestBody.PlayerId);
            if (player == null)
                throw new Exception($"{requestBody.PlayerId} was not found");

            player.VoteForPlayerId = requestBody.VoteForPlayerId;
            await DDBContext.SaveAsync(player);

            var scanResult = DDBContext.ScanAsync<Player>(new[] { new ScanCondition("GameId", Amazon.DynamoDBv2.DocumentModel.ScanOperator.Equal, player.GameId) });
            var players = await scanResult.GetRemainingAsync();

            Game game = await DDBContext.LoadAsync<Game>(player.GameId);
            if (game == null)
                throw new Exception($"{player.GameId} was not found");

            bool werewolvesWon = false;

            context.Logger.LogLine($"{players.Count(p => p.IsReady)} Ready : {players.Count(p => !p.IsReady)} Not Ready - Game State {game.State}");

            if (players.All(p => p.VoteForPlayerId != Guid.Empty) && game.State == GameStateEnum.InGame)
            {
                // Find the most voted player
                var q = (from p in players
                        group p by p.VoteForPlayerId into g
                        let count = g.Count()
                        orderby count descending
                        select new { Value = g.Key, Count = count }).ToList();
                
                int highestVote = q[0].Count;
                List<Guid> highestVotedPlayerGuids = q.Where(p => p.Count == highestVote).Select(p => p.Value).ToList();
                List<Player> highestVotedPlayers = players.Where(p => highestVotedPlayerGuids.Contains(p.PlayerId)).ToList();

                // If its a tie then humans win if any werewolf are picked
                werewolvesWon = !highestVotedPlayers.Any(p => p.PlayerType == PlayerTypeEnum.Werewolf);

                game.State = GameStateEnum.GameOver;
                await DDBContext.SaveAsync(game);
            }

            return new APIGatewayProxyResponse
            {
                StatusCode = (int)HttpStatusCode.OK,
                Body = JsonConvert.SerializeObject(new VoteResponse()
                {
                    Players = players.Select(p => new PlayerViewModel { PlayerId = p.PlayerId, Name = p.Name, IsReady = p.IsReady, PlayerType = p.PlayerType, IsNPC = p.IsNPC, VoteForPlayerId = p.VoteForPlayerId, ColourBrightness = p.ColourBrightness, ColourHue = p.ColourHue, ColourSaturation = p.ColourSaturation }).ToList(),
                    EveryoneVoted = game.State == GameStateEnum.GameOver,
                    WerewolvesWon = werewolvesWon
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
            public bool IsReady { get; set; }
        }

        public class IsReadyResponse
        {
            public List<PlayerViewModel> Players { get; set; }
            public GameStateEnum GameState { get; set; }
            public PlayerTypeEnum PlayerType { get; set; }
            public Guid CurrentPlayerId { get; set; }
        }

        public class PlayerTurnRequest
        {
            public Guid PlayerId { get; set; }
            public Guid SeenPlayerId { get; set; }
            public Guid RobbedPlayerId { get; set; }
            public Guid TroubledPlayerId1 { get; set; }
            public Guid TroubledPlayerId2 { get; set; }
        }

        public class PlayerTurnResponse
        {
            public List<PlayerViewModel> Players { get; set; }
            public GameStateEnum GameState { get; set; }
            public PlayerTypeEnum PlayerType { get; set; }
            public Guid CurrentPlayerId { get; set; }
        }

        public class VoteRequest
        {
            public Guid PlayerId { get; set; }
            public Guid VoteForPlayerId { get; set; }
        }

        public class VoteResponse
        {
            public bool WerewolvesWon { get; set; }
            public bool EveryoneVoted { get; set; }
            public List<PlayerViewModel> Players { get; set; }
        }


        public class PlayerViewModel
        {
            public Guid PlayerId { get; set; }
            public string Name { get; set; }
            public bool IsReady { get; set; }
            public bool IsNPC { get; set; }
            public PlayerTypeEnum PlayerType { get; set; }
            public Guid VoteForPlayerId { get; set; }
            public double ColourHue { get; set; }
            public double ColourSaturation { get; set; }
            public double ColourBrightness { get; set; }
        }

    }
}
