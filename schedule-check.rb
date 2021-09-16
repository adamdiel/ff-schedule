require 'rubygems'
require 'mechanize'
require 'json'

LEAGUE_ID =  # ENTER LEAGUE ID HERE

def check_matchup_count(team, opponent, division_rival, schedule)
    games = schedule["schedule"].select { |game| game["away"]["teamId"] == team["id"] || game["home"]["teamId"] == team["id"] }
    game_count = 0
    for game in games do
        if game["away"]["teamId"] == opponent["id"] || game["home"]["teamId"] == opponent["id"]
            game_count += 1
        end
    end
    if division_rival
        if game_count == 2
            return true
        else
            puts team["location"] + " " + team["nickname"] + " vs " + opponent["location"] + " " + opponent["nickname"]
            puts game_count
            puts
        end
    else
        if game_count == 1
            return true
        else
            puts team["location"] + " " + team["nickname"] + " vs " + opponent["location"] + " " + opponent["nickname"]
            puts game_count
            puts
        end
    end
end


def is_division_rival(team, opponent)
    if team["divisionId"] == opponent["divisionId"]
        true
    else
        false
    end
end

def check_opponents(team, opponents, schedule)
    for opponent in opponents do
        division_rival = is_division_rival(team, opponent)
        check_matchup_count(team, opponent, division_rival, schedule)
    end
end

def get_opponents(teamId, teams)
    teams.select { |team| team["id"] != teamId}
end

def check_teams_schedule(schedule, teams)
    for team in teams do
        opponents = get_opponents(team["id"], teams)
        check_opponents(team, opponents, schedule)
    end
end

def lookup_team(teamId, teams)
    team = teams.detect { |team| team["id"] == teamId}
    team = team["location"] + " " + team["nickname"]
end

def print_each_week(schedule, teams)
    matchup_index = 0
    for matchup in schedule["schedule"] do
        away_team = lookup_team(matchup['away']['teamId'], teams)
        home_team = lookup_team(matchup['home']['teamId'], teams)
        puts "#{away_team} vs #{home_team}"
        matchup_index += 1
        if matchup_index % 5 == 0
            puts
        end
    end
end

def get_teams(schedule)
    schedule["teams"]
end

def get_divisions(schedule)
    schedule["settings"]["scheduleSettings"]["divisions"]
end

def get_schedule(agent)
    url = "https://fantasy.espn.com/apis/v3/games/ffl/seasons/2021/segments/0/leagues/#{LEAGUE_ID}?view=mScoreboard"
    schedule = JSON.parse(agent.get(url).content)
    schedule
end

agent = Mechanize.new
schedule = get_schedule(agent)
divisions = get_divisions(schedule)
teams = get_teams(schedule)
check_teams_schedule(schedule, teams)
# print_each_week(schedule, teams)
