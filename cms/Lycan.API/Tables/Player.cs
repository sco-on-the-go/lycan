using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

using Amazon;
using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.DataModel;

namespace Lycan.API
{
    public class Player
    {
        [DynamoDBHashKey]
        public Guid PlayerId { get; set; }
        [DynamoDBRangeKey]
        public Guid GameId { get; set; }
        public string Name { get; set; }
        public bool IsReady { get; set; }
    }
}
