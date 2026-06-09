#!/usr/bin/env python3
"""ASO keyword research using the public iTunes Search API.
Computes popularity (5-100) and difficulty (1-100) scores based on RespectASO algorithms.
Usage: python3 aso_research.py <keyword> [--country us] [--batch kw1,kw2,kw3]
"""
import json, math, sys, time, urllib.request, urllib.parse
from datetime import datetime
from typing import Optional

ITUNES_SEARCH = "https://itunes.apple.com/search"
RATE_LIMIT_SLEEP = 2.0

# ── iTunes Search API ──────────────────────────────────────────────────

def search_apps(keyword: str, country: str = "us", limit: int = 25) -> list[dict]:
    params = urllib.parse.urlencode({
        "term": keyword, "country": country, "entity": "software", "limit": limit
    })
    url = f"{ITUNES_SEARCH}?{params}"
    req = urllib.request.Request(url, headers={"User-Agent": "ASO-Research/1.0"})
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = json.loads(resp.read())
        return [{
            "trackId": r.get("trackId"),
            "trackName": r.get("trackName", ""),
            "averageUserRating": r.get("averageUserRating", 0),
            "userRatingCount": r.get("userRatingCount", 0),
            "releaseDate": r.get("releaseDate", ""),
            "currentVersionReleaseDate": r.get("currentVersionReleaseDate", ""),
            "primaryGenreName": r.get("primaryGenreName", ""),
            "sellerName": r.get("sellerName", ""),
            "bundleId": r.get("bundleId", ""),
        } for r in data.get("results", [])]
    except Exception as e:
        print(f"  [warn] iTunes API error: {e}", file=sys.stderr)
        return []

# ── Helpers ─────────────────────────────────────────────────────────────

def _interpolate(value: float, bands: list[tuple[float, float]]) -> float:
    if value <= bands[0][0]: return bands[0][1]
    if value >= bands[-1][0]: return bands[-1][1]
    for i in range(1, len(bands)):
        if value <= bands[i][0]:
            prev_t, prev_s = bands[i-1]
            curr_t, curr_s = bands[i]
            if prev_t <= 0: ratio = value / curr_t
            else: ratio = math.log(value / prev_t) / math.log(curr_t / prev_t)
            return prev_s + (curr_s - prev_s) * ratio
    return bands[-1][1]

def _linear_interpolate(value: float, bands: list[tuple[float, float]]) -> float:
    if value <= bands[0][0]: return bands[0][1]
    if value >= bands[-1][0]: return bands[-1][1]
    for i in range(1, len(bands)):
        if value <= bands[i][0]:
            prev_t, prev_s = bands[i-1]
            curr_t, curr_s = bands[i]
            ratio = (value - prev_t) / (curr_t - prev_t)
            return prev_s + (curr_s - prev_s) * ratio
    return bands[-1][1]

def _title_match(title: str, keyword: str) -> tuple[bool, bool]:
    title_lower = title.lower()
    kw_lower = keyword.lower()
    exact = kw_lower in title_lower
    tokens = kw_lower.split()
    all_words = all(t in title_lower.split() or t in title_lower for t in tokens)
    return exact, all_words or exact

def _app_age_years(app: dict) -> float:
    try:
        released = datetime.fromisoformat(app["releaseDate"].replace("Z", "+00:00"))
        age = (datetime.now(released.tzinfo) - released).days / 365.25
        return max(0.5, age)
    except: return 2.0

# ── Popularity Score (5-100) ───────────────────────────────────────────

def compute_popularity(competitors: list[dict], keyword: str) -> Optional[int]:
    n = len(competitors)
    if n == 0: return None

    # Signal 1: Result count (0-25)
    result_score = min(25, n * 2.5)

    # Signal 2: Leader strength (0-30)
    top_half = competitors[:max(1, n // 2)]
    leader_reviews = max((c["userRatingCount"] for c in top_half), default=0)
    leader_bands = [(10,1),(100,5),(1000,10),(10000,17),(100000,24),(1000000,30)]
    leader_score = _interpolate(leader_reviews, leader_bands)

    # Signal 3: Title match density (0-20)
    title_matches = sum(1 for c in competitors if _title_match(c["trackName"], keyword)[1])
    match_ratio = title_matches / n
    title_score = min(20, match_ratio * 40)

    # Signal 4: Market depth (0-10)
    ratings = sorted([c["userRatingCount"] for c in competitors])
    median_ratings = ratings[len(ratings) // 2] if ratings else 0
    depth_bands = [(10,0.5),(100,3),(1000,5),(10000,8),(50000,10)]
    depth_score = _interpolate(median_ratings, depth_bands)

    # Signal 5: Keyword specificity penalty (-5 to -28)
    word_count = len(keyword.split())
    sp_points = [(1,0),(2,-3),(3,-8),(4,-15),(5,-22),(6,-28)]
    specificity_penalty = _linear_interpolate(min(word_count, 6), sp_points)

    # Signal 6: Exact phrase match bonus (0-15)
    exact_matches = sum(1 for c in competitors if _title_match(c["trackName"], keyword)[0])
    exact_ratio = exact_matches / n
    exact_bonus = min(15, exact_ratio * 50)

    # Dampening
    sample_dampening = min(1.0, n / 10)
    title_score *= sample_dampening
    exact_bonus *= sample_dampening

    # Relevance dampening
    relevance_sum = sum(1.0 if _title_match(c["trackName"], keyword)[1] else 0.3 for c in competitors)
    relevance = max(0.3, min(1.0, (relevance_sum / n) * 2.6))
    result_score *= relevance
    leader_score *= relevance
    depth_score *= relevance

    total = int(result_score + leader_score + title_score + depth_score + specificity_penalty + exact_bonus)
    return max(5, min(100, total))

# ── Difficulty Score (1-100) ────────────────────────────────────────────

def compute_difficulty(competitors: list[dict], keyword: str) -> Optional[int]:
    n = len(competitors)
    if n == 0: return None

    # Rating volume (30%)
    ratings = sorted([c["userRatingCount"] for c in competitors])
    median_ratings = ratings[len(ratings) // 2] if ratings else 0
    vol_bands = [(50,5),(200,15),(500,30),(2000,50),(5000,65),(10000,78),(25000,88),(100000,95)]
    rating_volume = _interpolate(median_ratings, vol_bands)

    # Review velocity (10%)
    velocities = []
    for c in competitors:
        age = _app_age_years(c)
        velocities.append(c["userRatingCount"] / age)
    velocities.sort()
    median_vel = velocities[len(velocities) // 2] if velocities else 0
    vel_bands = [(10,5),(50,15),(200,30),(1000,50),(5000,70),(20000,85),(50000,95)]
    review_velocity = _interpolate(median_vel, vel_bands)

    # Dominant players (20%)
    log_ceiling = 7.0  # log10(10M)
    dominance_total, weight_sum = 0.0, 0.0
    for i, c in enumerate(competitors):
        d = min(1.0, math.log10(max(c["userRatingCount"], 1)) / log_ceiling)
        w = 2.0 if i < n // 2 else 1.0
        dominance_total += d * w
        weight_sum += w
    dominant_players = min(100, (dominance_total / max(weight_sum, 1)) * 100)

    # Rating quality (10%)
    weighted_rating, weight_total = 0.0, 0.0
    for c in competitors:
        w = math.log1p(c["userRatingCount"])
        weighted_rating += c["averageUserRating"] * w
        weight_total += w
    avg_quality = weighted_rating / max(weight_total, 1)
    qual_bands = [(0,0),(3,20),(3.5,35),(4,50),(4.3,70),(4.5,85),(5,100)]
    rating_quality = _linear_interpolate(avg_quality, qual_bands)

    # Market age (10%)
    ages = [_app_age_years(c) for c in competitors]
    avg_age = sum(ages) / max(len(ages), 1)
    age_bands = [(0.5,10),(1,20),(2,35),(3,50),(5,70),(8,85),(10,100)]
    market_age = _linear_interpolate(avg_age, age_bands)

    # Publisher diversity (10%)
    unique_pubs = len(set(c["sellerName"] for c in competitors if c["sellerName"]))
    publisher_diversity = min(100, (unique_pubs / max(n, 1)) * 100)

    # Title relevance (10%)
    title_matches = sum(1 for c in competitors if _title_match(c["trackName"], keyword)[1])
    title_relevance = min(100, (title_matches / max(n, 1)) * 100)

    # Dampening
    sample_dampening = min(1.0, n / 10)
    publisher_diversity *= sample_dampening
    title_relevance *= sample_dampening
    dominant_players *= sample_dampening
    rating_quality *= sample_dampening

    # Weighted total
    raw = int(
        rating_volume * 0.30 + review_velocity * 0.10 + dominant_players * 0.20 +
        rating_quality * 0.10 + market_age * 0.10 + publisher_diversity * 0.10 +
        title_relevance * 0.10
    )
    total = max(1, min(100, raw))

    # Post-processing: small result set cap
    small_caps = {1: 10, 2: 20, 3: 31, 4: 40}
    if n in small_caps and total > small_caps[n]:
        total = small_caps[n]

    # Weak leader cap
    leader_reviews = max((c["userRatingCount"] for c in competitors[:max(1, n // 2)]), default=0)
    match_ratio = title_matches / max(n, 1)
    if leader_reviews < 1000:
        leader_cap = int(15 + 35 * math.log10(leader_reviews + 1) / math.log10(1001))
        if match_ratio > 0.2:
            total = int(leader_cap + (total - leader_cap) * match_ratio)
        else:
            total = min(total, leader_cap)

    return max(1, min(100, total))

# ── Main ───────────────────────────────────────────────────────────────

def analyze_keyword(keyword: str, country: str = "us") -> dict:
    competitors = search_apps(keyword, country)
    popularity = compute_popularity(competitors, keyword)
    difficulty = compute_difficulty(competitors, keyword)

    top_apps = [{"name": c["trackName"], "reviews": c["userRatingCount"],
                 "rating": round(c["averageUserRating"], 1),
                 "seller": c["sellerName"]}
                for c in competitors[:5]]

    return {
        "keyword": keyword,
        "country": country,
        "popularity": popularity,
        "difficulty": difficulty,
        "competitors_found": len(competitors),
        "top_5_apps": top_apps,
        "verdict": _verdict(popularity, difficulty),
    }

def _verdict(pop: Optional[int], diff: Optional[int]) -> str:
    if pop is None or diff is None: return "insufficient data"
    if pop >= 20 and diff < 50: return "SWEET SPOT (popularity >= 20, difficulty < 50)"
    if pop >= 20 and diff >= 50: return "HIGH COMPETITION (popular but hard to rank)"
    if pop < 20 and diff < 50: return "HIDDEN GEM (low volume but easy to rank)"
    return "AVOID (low volume, high competition)"

def main():
    import argparse
    parser = argparse.ArgumentParser(description="ASO Keyword Research")
    parser.add_argument("keyword", nargs="?", help="Keyword to analyze")
    parser.add_argument("--country", default="us", help="Country code (default: us)")
    parser.add_argument("--batch", help="Comma-separated keywords for batch analysis")
    args = parser.parse_args()

    keywords = args.batch.split(",") if args.batch else [args.keyword] if args.keyword else []
    if not keywords:
        parser.print_help()
        sys.exit(1)

    results = []
    for i, kw in enumerate(keywords):
        kw = kw.strip()
        if i > 0: time.sleep(RATE_LIMIT_SLEEP)
        print(f"Analyzing: {kw} ({args.country})...", file=sys.stderr)
        results.append(analyze_keyword(kw, args.country))

    print(json.dumps(results if len(results) > 1 else results[0], indent=2))

if __name__ == "__main__":
    main()
