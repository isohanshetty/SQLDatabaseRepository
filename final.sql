
###Q1 View to show venue wins info, before a match starts, to display venue wins /losses for each team (current and total seasons)

create view VenueWinInfo as 
with VenueTotalWinCount as (
	select venueID, winner, count(winner) as TotalWinCount 
    from ipl.match_details
	group by venueID, winner)
    
, VenueCurrentWinCount as (
	select venueID, winner, count(winner) as CurrentSeasonWinCount 
    from ipl.match_details
		where season = (select max(season) from ipl.match_details)
	group by venueID, winner)
    
, AllWins as (
	select a.venueID, a.winner as team, TotalWinCount, CurrentSeasonWinCount
    from VenueTotalWinCount a left join VenueCurrentWinCount b
    on a.venueID = b.venueID and a.winner = b.winner)

select id, venue, city, team,
	ifnull(TotalWinCount, 'No Wins Yet') as TotalWinCount,
    ifnull(CurrentSeasonWinCount, 'No Wins Yet') as CurrentSeasonWinCount
	from ipl.venue a left join AllWins b on a.id = b.venueID;


################################################
#q2
select Name, FullName, BirthInfo, 
	left(BirthInfo,regexp_instr(BirthInfo, '[0-9]',1,6)) as BirthDate,
    right(BirthInfo,length(BirthInfo) -(regexp_instr(BirthInfo, '[0-9]',1,6) +2)) as BirthPlace
from ipl.players_info_with_keys;



################################################

###Q3

#match = 980947, old - SA Yadav - 271f83cd, new - AB Dinda - 66b30f71

delimiter &&
create procedure ipl.UpdateMatchLineup (in Matchid int, in OldId varchar(255), in NewName varchar(255), in NewId varchar(255))
begin
	update ipl.lineup set Players = NewName, identifier = NewId
    where Match_ID = Matchid and identifier = OldId;
end;

#call UpdateMatchLineup (980947, '271f83cd', 'AB Dinda', '66b30f71');

SELECT * FROM ipl.lineup where Match_ID = 980947 order by 2;


#####################################

###Q4

delimiter &&
create procedure ipl.UpdateMatchWinner (in Matchid int, in NewWinner varchar(255), in WinBy int, in WinType varchar(255))
begin
	update ipl.match_details set winner = NewWinner, win_by = WinBy, winner_type = WinType
    where Match_ID = Matchid;
end;

#call UpdateMatchWinner (829779, 'Royal Challengers Bangalore', 99, 'runs');

SELECT * FROM ipl.match_details where Match_id = 829779;


##############################################

###Q5 Stored proc to update venue id in case of venue changes

delimiter &&
create procedure ipl.UpdateMatchVenue (in Matchid int, in NewVenueId varchar(255))
begin
	update ipl.match_details set venueID = NewVenueId
    where Match_ID = Matchid;
end;

#call UpdateMatchVenue (829779, 'V031');

SELECT * FROM ipl.match_details where Match_id = 829779;


################################################33


###Q6 Check condition in tables where team names are present to only accept the exact IPL team name

CREATE TABLE ipl.lineup (
  Match_ID int,
  Team text,
  Players text,
  identifier text,
  check (Team in (
	'Chennai Super Kings',
	'Deccan Chargers',
	'Delhi Capitals',
	'Delhi Daredevils',
	'Gujarat Lions',
	'Gujarat Titans',
	'Kings XI Punjab',
	'Kochi Tuskers Kerala',
	'Kolkata Knight Riders',
	'Lucknow Super Giants',
	'Mumbai Indians',
	'Pune Warriors',
	'Punjab Kings',
	'Rajasthan Royals',
	'Rising Pune Supergiant',
	'Rising Pune Supergiants',
	'Royal Challengers Bangalore',
	'Sunrisers Hyderabad')));




