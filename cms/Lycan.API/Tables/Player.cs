using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

using Amazon;
using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.DataModel;

namespace Lycan.API
{
    public enum PlayerTypeEnum
    {
        Werewolf = 1,
        Seer,
        Troublemaker,
        Robber,
        Villager
    }

    public class Player
    {
        [DynamoDBHashKey]
        public Guid PlayerId { get; set; }
        public Guid GameId { get; set; }
        public string Name { get; set; }
        public bool IsReady { get; set; }
        public bool IsNPC { get; set; }
        public PlayerTypeEnum PlayerType { get; set; }
    }
}
