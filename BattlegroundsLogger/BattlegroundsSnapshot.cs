using System;
using System.Collections.Generic;
using Newtonsoft.Json;

namespace BattlegroundsLogger
{
    public class BattlegroundsSnapshot
    {
        [JsonProperty("schema_version")]
        public string SchemaVersion { get; set; } = "1.0.0";

        [JsonProperty("plugin_version")]
        public string PluginVersion { get; set; } = "1.0.0";

        [JsonProperty("session_id")]
        public string SessionId { get; set; }

        [JsonProperty("timestamp_utc")]
        public DateTime TimestampUtc { get; set; }

        [JsonProperty("turn")]
        public int Turn { get; set; }

        [JsonProperty("phase")]
        public string Phase { get; set; } = "shop";

        [JsonProperty("tavern_tier")]
        public int TavernTier { get; set; }

        [JsonProperty("gold")]
        public int Gold { get; set; }

        [JsonProperty("health")]
        public int Health { get; set; }

        [JsonProperty("armor")]
        public int Armor { get; set; }

        [JsonProperty("frozen")]
        public bool Frozen { get; set; }

        [JsonProperty("available_tribes")]
        public List<string> AvailableTribes { get; set; } = new List<string>();

        [JsonProperty("hero")]
        public HeroInfo Hero { get; set; } = new HeroInfo();

        [JsonProperty("economy")]
        public EconomyInfo Economy { get; set; } = new EconomyInfo();

        [JsonProperty("shop")]
        public List<MinionInfo> Shop { get; set; } = new List<MinionInfo>();

        [JsonProperty("board")]
        public List<MinionInfo> Board { get; set; } = new List<MinionInfo>();

        [JsonProperty("notes")]
        public string Notes { get; set; }
    }

    public class HeroInfo
    {
        [JsonProperty("player_hero_name")]
        public string PlayerHeroName { get; set; }

        [JsonProperty("player_hero_id")]
        public string PlayerHeroId { get; set; }

        [JsonProperty("opponent_hero_name")]
        public string OpponentHeroName { get; set; }

        [JsonProperty("opponent_hero_id")]
        public string OpponentHeroId { get; set; }
    }

    public class EconomyInfo
    {
        [JsonProperty("reroll_cost")]
        public int RerollCost { get; set; } = 1;

        [JsonProperty("freeze_available")]
        public bool FreezeAvailable { get; set; } = true;

        [JsonProperty("triples_in_hand")]
        public int TriplesInHand { get; set; }

        [JsonProperty("rolls_this_turn")]
        public int RollsThisTurn { get; set; }
    }

    public class MinionInfo
    {
        [JsonProperty("name")]
        public string Name { get; set; }

        [JsonProperty("tier")]
        public int Tier { get; set; }

        [JsonProperty("tribe")]
        public string Tribe { get; set; } = "NEUTRAL";

        [JsonProperty("keywords")]
        public List<string> Keywords { get; set; } = new List<string>();

        [JsonProperty("golden")]
        public bool Golden { get; set; }

        [JsonProperty("attack")]
        public int? Attack { get; set; }

        [JsonProperty("health")]
        public int? Health { get; set; }

        [JsonProperty("enchantments")]
        public List<string> Enchantments { get; set; } = new List<string>();

        [JsonProperty("position")]
        public int Position { get; set; }

        [JsonProperty("entity_id")]
        public int? EntityId { get; set; }
    }
}