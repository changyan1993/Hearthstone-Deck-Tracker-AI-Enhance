using System;
using System.Collections.Generic;
using System.Linq;
using HearthDb.Enums;
using Hearthstone_Deck_Tracker.API;
using Hearthstone_Deck_Tracker.Hearthstone;
using Hearthstone_Deck_Tracker.Hearthstone.Entities;
using Hearthstone_Deck_Tracker.Utility.Logging;
using static HearthDb.Enums.GameTag;

namespace BattlegroundsLogger
{
    public static class BattlegroundsStateExtractor
    {
        public static BattlegroundsSnapshot ExtractCurrentState(int turn)
        {
            try
            {
                var game = Core.Game;
                if (game == null || !game.IsBattlegroundsMatch)
                    return null;

                var snapshot = new BattlegroundsSnapshot
                {
                    Turn = turn,
                    Phase = "shop"
                };

                ExtractPlayerInfo(snapshot, game);
                ExtractHeroInfo(snapshot, game);
                ExtractEconomyInfo(snapshot, game);
                ExtractAvailableTribes(snapshot, game);
                ExtractShopMinions(snapshot, game);
                ExtractBoardMinions(snapshot, game);

                return snapshot;
            }
            catch (Exception ex)
            {
                Log.Error($"[BG-Logger] Failed to extract game state: {ex}");
                return null;
            }
        }

        private static void ExtractPlayerInfo(BattlegroundsSnapshot snapshot, GameV2 game)
        {
            try
            {
                var playerEntity = game.Entities.Values.FirstOrDefault(e => 
                    e.IsPlayer && e.IsControlledBy(game.Player.Id));

                if (playerEntity != null)
                {
                    snapshot.Health = playerEntity.GetTag(HEALTH) - playerEntity.GetTag(DAMAGE);
                    snapshot.Armor = playerEntity.GetTag(ARMOR);
                    snapshot.TavernTier = playerEntity.GetTag(PLAYER_TECH_LEVEL);
                    
                    var resources = playerEntity.GetTag(RESOURCES);
                    var resourcesUsed = playerEntity.GetTag(RESOURCES_USED);
                    snapshot.Gold = Math.Max(0, resources - resourcesUsed);
                }

                var bobsShop = game.Entities.Values.FirstOrDefault(e =>
                    e.CardId == "TB_BaconShop_HERO_PH");
                
                if (bobsShop != null)
                {
                    snapshot.Frozen = bobsShop.GetTag(FROZEN) == 1;
                }
            }
            catch (Exception ex)
            {
                Log.Error($"[BG-Logger] Error extracting player info: {ex}");
            }
        }

        private static void ExtractHeroInfo(BattlegroundsSnapshot snapshot, GameV2 game)
        {
            try
            {
                var playerHero = game.Entities.Values.FirstOrDefault(e =>
                    e.IsHero && e.IsInZone(Zone.PLAY) && e.IsControlledBy(game.Player.Id));

                if (playerHero != null)
                {
                    snapshot.Hero.PlayerHeroId = playerHero.CardId;
                    snapshot.Hero.PlayerHeroName = playerHero.Card?.Name ?? playerHero.CardId;
                }

                var opponentHero = game.Entities.Values.FirstOrDefault(e =>
                    e.IsHero && e.IsInZone(Zone.PLAY) && e.IsControlledBy(game.Opponent.Id));

                if (opponentHero != null)
                {
                    snapshot.Hero.OpponentHeroId = opponentHero.CardId;
                    snapshot.Hero.OpponentHeroName = opponentHero.Card?.Name ?? opponentHero.CardId;
                }
            }
            catch (Exception ex)
            {
                Log.Error($"[BG-Logger] Error extracting hero info: {ex}");
            }
        }

        private static void ExtractEconomyInfo(BattlegroundsSnapshot snapshot, GameV2 game)
        {
            try
            {
                snapshot.Economy.RerollCost = 1;
                snapshot.Economy.FreezeAvailable = true;
                
                var handEntities = game.Entities.Values.Where(e =>
                    e.IsInHand && e.IsControlledBy(game.Player.Id) && e.IsMinion);

                var tripleRewards = handEntities.Where(e =>
                    e.CardId != null && e.CardId.Contains("Triple"));
                
                snapshot.Economy.TriplesInHand = tripleRewards.Count();

                snapshot.Economy.RollsThisTurn = 0;
            }
            catch (Exception ex)
            {
                Log.Error($"[BG-Logger] Error extracting economy info: {ex}");
            }
        }

        private static void ExtractAvailableTribes(BattlegroundsSnapshot snapshot, GameV2 game)
        {
            try
            {
                var availableRaces = BattlegroundsUtils.GetAvailableRaces();
                if (availableRaces != null)
                {
                    snapshot.AvailableTribes = availableRaces
                        .Select(r => r.ToString().ToUpperInvariant())
                        .ToList();
                }
            }
            catch (Exception ex)
            {
                Log.Error($"[BG-Logger] Error extracting available tribes: {ex}");
            }
        }

        private static void ExtractShopMinions(BattlegroundsSnapshot snapshot, GameV2 game)
        {
            try
            {
                var shopMinions = game.Entities.Values
                    .Where(e => e.IsMinion && e.IsInZone(Zone.PLAY) && 
                           e.GetTag(ZONE_POSITION) > 0 &&
                           (e.GetTag(CONTROLLER) == game.Player.Id || 
                            e.CardId?.StartsWith("TB_BaconShop") == true))
                    .Where(e => e.GetTag(GameTag.IS_BACON_POOL_MINION) == 1)
                    .OrderBy(e => e.GetTag(ZONE_POSITION))
                    .ToList();

                int position = 1;
                foreach (var minion in shopMinions)
                {
                    var minionInfo = ExtractMinionInfo(minion, position++);
                    if (minionInfo != null)
                        snapshot.Shop.Add(minionInfo);
                }
            }
            catch (Exception ex)
            {
                Log.Error($"[BG-Logger] Error extracting shop minions: {ex}");
            }
        }

        private static void ExtractBoardMinions(BattlegroundsSnapshot snapshot, GameV2 game)
        {
            try
            {
                var boardMinions = game.Entities.Values
                    .Where(e => e.IsMinion && e.IsInZone(Zone.PLAY) && 
                           e.IsControlledBy(game.Player.Id) &&
                           e.GetTag(GameTag.IS_BACON_POOL_MINION) != 1)
                    .OrderBy(e => e.GetTag(ZONE_POSITION))
                    .ToList();

                int position = 1;
                foreach (var minion in boardMinions)
                {
                    var minionInfo = ExtractMinionInfo(minion, position++);
                    if (minionInfo != null)
                        snapshot.Board.Add(minionInfo);
                }
            }
            catch (Exception ex)
            {
                Log.Error($"[BG-Logger] Error extracting board minions: {ex}");
            }
        }

        private static MinionInfo ExtractMinionInfo(Entity entity, int position)
        {
            try
            {
                if (entity?.Card == null)
                    return null;

                var minion = new MinionInfo
                {
                    Name = entity.Card.Name ?? entity.CardId,
                    Position = position,
                    EntityId = entity.Id,
                    Attack = entity.GetTag(ATK),
                    Health = entity.GetTag(HEALTH) - entity.GetTag(DAMAGE),
                    Golden = entity.GetTag(PREMIUM) == 1,
                    Tier = entity.Card.TechLevel > 0 ? entity.Card.TechLevel : entity.GetTag(TECH_LEVEL)
                };

                if (minion.Attack == 0 && minion.Health == 0)
                {
                    minion.Attack = entity.Card.Attack;
                    minion.Health = entity.Card.Health;
                }

                var tribe = GetMinionTribe(entity);
                minion.Tribe = tribe ?? "NEUTRAL";

                var keywords = ExtractKeywords(entity);
                minion.Keywords = keywords;

                var enchantments = ExtractEnchantments(entity);
                minion.Enchantments = enchantments;

                return minion;
            }
            catch (Exception ex)
            {
                Log.Error($"[BG-Logger] Error extracting minion info: {ex}");
                return null;
            }
        }

        private static string GetMinionTribe(Entity entity)
        {
            try
            {
                if (entity.Card?.Race != null)
                {
                    try 
                    {
                        if (Enum.TryParse<Race>(entity.Card.Race.ToString(), out var cardRace) && cardRace != Race.INVALID)
                        {
                            return cardRace.ToString().ToUpperInvariant();
                        }
                    }
                    catch { }
                }

                var tribeTag = entity.GetTag(CARDRACE);
                if (tribeTag > 0)
                {
                    var race = (Race)tribeTag;
                    if (race != Race.INVALID)
                        return race.ToString().ToUpperInvariant();
                }

                return "NEUTRAL";
            }
            catch
            {
                return "NEUTRAL";
            }
        }

        private static List<string> ExtractKeywords(Entity entity)
        {
            var keywords = new List<string>();

            try
            {
                if (entity.GetTag(TAUNT) == 1)
                    keywords.Add("TAUNT");
                if (entity.GetTag(DIVINE_SHIELD) == 1)
                    keywords.Add("DIVINE_SHIELD");
                if (entity.GetTag(REBORN) == 1)
                    keywords.Add("REBORN");
                if (entity.GetTag(POISONOUS) == 1 || entity.GetTag(VENOMOUS) == 1)
                    keywords.Add("POISONOUS");
                if (entity.GetTag(WINDFURY) == 1)
                    keywords.Add("WINDFURY");
                if (entity.GetTag(DEATHRATTLE) == 1)
                    keywords.Add("DEATHRATTLE");
                if (entity.GetTag(BATTLECRY) == 1)
                    keywords.Add("BATTLECRY");
                if (entity.GetTag(AVENGE) > 0)
                    keywords.Add("AVENGE");
                if (entity.GetTag(START_OF_COMBAT) == 1)
                    keywords.Add("START_OF_COMBAT");
            }
            catch (Exception ex)
            {
                Log.Error($"[BG-Logger] Error extracting keywords: {ex}");
            }

            return keywords;
        }

        private static List<string> ExtractEnchantments(Entity entity)
        {
            var enchantments = new List<string>();

            try
            {
                var attachedEntities = Core.Game.Entities.Values
                    .Where(e => e.GetTag(ATTACHED) == entity.Id && e.IsEnchantment)
                    .Select(e => e.Card?.Name ?? e.CardId)
                    .Where(name => !string.IsNullOrEmpty(name))
                    .ToList();

                enchantments.AddRange(attachedEntities);
            }
            catch (Exception ex)
            {
                Log.Error($"[BG-Logger] Error extracting enchantments: {ex}");
            }

            return enchantments;
        }
    }
}