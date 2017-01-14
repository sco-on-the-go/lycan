using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

using Amazon;
using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.DataModel;

namespace Lycan.API
{
    public enum GameStateEnum
    {
        Lobby = 1,
        InGame,
        GameOver
    }

    public class Game
    {
        [DynamoDBHashKey]
        public Guid GameId { get; set; }
        public string Name { get; set; }
        public GameStateEnum State { get; set; }
    }
}
