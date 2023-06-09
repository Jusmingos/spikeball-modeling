#lang forge
open "spikeball.frg"
option problem_type temporal
option max_tracelength 40
// option min_tracelength 7

-- Team 1 or Team 2 always wins [THEOREM]
pred always_team_one_or_two_wins {
    always {
        eventually {
            some s: SBState {
                s.score[Team1] = 2 or s.score[Team2] = 2
            }
        }
    }
}

-- Team one always wins [UNSAT]
pred team_one_always_wins {
    always {
        eventually {
            some s: SBState {
                s.score[Team1] = 2
            }
        }
    }
}

-- Ball gets passed from P1 on Team 1 to P4 on Team 2 [UNSAT]
pred illegal_pass {
    eventually {
        some s: SBState {
            s.ball = North
            s'.ball' = South
        }
    }
}

-- Team two always wins [UNSAT]
pred team_two_always_wins {
    always {
        eventually {
            some s: SBState {
                s.score[Team2] = 2
            }
        }
    }
}

-- The team that serves always wins [UNSAT]
pred serving_team_always_wins {
    always {
        eventually {
            some s: SBState {
                s.score[s.serving_team] = 2
            }
        }
    }
}

-- The team that doesn't serve always wins [UNSAT]
pred non_serving_team_always_wins {
    always {
        some s: SBState {
            (s.serving_team = Team1) => {
                eventually s.score[Team2] = 2
            } else {
                eventually s.score[Team1] = 2
            }
        }
    }
}


// The game will always maximum 3 touches (never less than 3 touches) [THEOREM]
pred max_3_touches {
    always {
        eventually {
            some s: SBState {
                s.num_touches = 3
            }
        }
    }
}


// Check that it’s possible for both teams to have 0 touches at the end of the game [SAT]
pred no_touches_used {
    always {
        eventually {
            some s: SBState {
                (s.score[Team1] = 2 or s.score[Team2] = 2) // 1 team has won
                s.num_touches = 0 // but no touches used
            }
        }
    }
}


// If a team gets a score, it's always from the ground to a person [THEOREM]
pred score_on_ground_to_server {
    some s, snext: SBState {
        snext = s.next
        
        some t: Team {
            (add[s.score[t], 1] = snext.score[t]) => {
                s.ball = Ground
                (t = Team1) => {
                    snext.ball = North
                } else {
                    snext.ball = South
                }
            }
        }
    }
}


// Players stay in their cardinal positions (P1 always North…) [THEOREM]
pred players_same_position {
     always {
        some p1, p2, p3, p4: Player {
            p1.position = North
            p2.position = West
            p3.position = East
            p4.position = South
        }
     }
}


// The serving team doesn’t stay the same throughout the game [SAT]
pred serving_team_changes {
    eventually {
        some s: SBState {
            s.serving_team != s'.serving_team'
        }
    }
}


// Check that it’s possible for both teams get at least one point (instead of one team gets 2 points and the other team has no point)s [SAT]
pred at_least_one_point {
    always {
        eventually {
            some s: SBState {
                s.score[Team1] = 1 and s.score[Team2] = 1
            }
        }
    }
}

test expect {
    // NOTE: 7 is the min number of states for satsfiablility. It's used in all the tests to reduce run time. 
    vacuity: {traces} for 7 SBState, exactly 4 Player, exactly 2 Team, 7 Int for {next is linear} is sat
    
    // sat tests
    noTouchesUsed: {traces implies no_touches_used} for exactly 4 Player, exactly 2 Team, 7 Int for {next is linear} is sat
    servingTeamChanges: {traces implies serving_team_changes} for exactly 4 Player, exactly 2 Team, 7 Int for {next is linear} is sat
    atLeastOnePoint: {traces implies at_least_one_point} for exactly 4 Player, exactly 2 Team, 7 Int for {next is linear} is sat
    
    // theorem tests
    alwaysExistsWinningTeam: {traces implies always_team_one_or_two_wins} for exactly 4 Player, exactly 2 Team, 7 Int for {next is linear} is theorem
    alwaysMaximizeTouches: {traces implies max_3_touches} for exactly 4 Player, exactly 2 Team, 7 Int for {next is linear} is theorem
    playerSamePosition: {traces implies players_same_position} for exactly 4 Player, exactly 2 Team, 7 Int for {next is linear} is theorem
    scoreOnGroundToServer: {traces implies score_on_ground_to_server} for exactly 4 Player, exactly 2 Team, 7 Int for {next is linear} is theorem

    
    // unsat tests
    teamOneAlwaysWins: {traces and team_one_always_wins} for exactly 4 Player, exactly 2 Team, 7 Int for {next is linear} is unsat
    teamTwoAlwaysWins: {traces and team_two_always_wins} for exactly 4 Player, exactly 2 Team, 7 Int for {next is linear} is unsat
    servingTeamAlwaysWins: {traces and serving_team_always_wins} for exactly 4 Player, exactly 2 Team, 7 Int for {next is linear} is unsat
    nonServingTeamAlwaysWins: {traces and non_serving_team_always_wins} for exactly 4 Player, exactly 2 Team, 7 Int for {next is linear} is unsat
    illegalPass: {traces and illegal_pass} for exactly 4 Player, exactly 2 Team, 7 Int for {next is linear} is unsat
}