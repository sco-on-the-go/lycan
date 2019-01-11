using Amazon;
using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.DataModel;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Lycan.Api
{
    public enum PlayerTypeEnum
    {
        Werewolf = 1,
        Seer,
        Robber,
        Troublemaker,
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
        public Guid VoteForPlayerId { get; set; }

        public double ColourHue { get; set; }
        public double ColourSaturation { get; set; }
        public double ColourBrightness { get; set; }

        public void GeneratePlayerColour()
        {
            var r = new Random();

            ColourHue = r.NextDouble();
            ColourSaturation = (r.NextDouble() / 2) + 0.5;
            ColourBrightness = (r.NextDouble() / 2) + 0.5;
        }

    }
}
