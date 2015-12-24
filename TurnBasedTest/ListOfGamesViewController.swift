//
//  ListOfGamesViewController.swift
//  TurnBasedTest
//
//  Created by Markos Hatzitaskos on 350/12/15.
//  Copyright © 2015 Markos Hatzitaskos. All rights reserved.
//

import UIKit
import GameKit

class ListOfGamesViewController: UITableViewController {
    
    var refreshTable = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self , selector: "reloadTable", name: "kMatchesLoaded", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self , selector: "reloadTable", name: "kReceivedTurnEvent", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self , selector: "reloadTable", name: "kEndTurnEvent", object: nil)
        
        refreshTable.addTarget(self, action: "reloadMatches", forControlEvents: UIControlEvents.ValueChanged)
        refreshTable.tintColor = UIColor.grayColor()
        refreshTable.attributedTitle = NSAttributedString(string: "LOADING", attributes: [NSForegroundColorAttributeName : UIColor.grayColor()])
        refreshTable.backgroundColor = UIColor.clearColor()
        tableView.addSubview(refreshTable)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadMatches() {
                
        GameCenterSingleton.sharedInstance.reloadMatches({
            (matches: [String:[GKTurnBasedMatch]]?) in
            
            if matches != nil {
                
                print("")
                print("Matches loaded")
                
                NSNotificationCenter.defaultCenter().postNotificationName("kMatchesLoaded", object: nil)
                
            } else {
                
                print("")
                print("There were no matches to load or some error occured")
                
                NSNotificationCenter.defaultCenter().postNotificationName("kMatchesLoaded", object: nil)
            }
            
            self.refreshTable.endRefreshing()
        })
    }
    
    func reloadTable() {
        print("")
        print("Reloading list of games table")
        
        if let allMatches = GameCenterSingleton.sharedInstance.matchDictionary["allMatches"] {
            
            GameCenterSingleton.sharedInstance.updateMatchDictionary(allMatches, completion: {
                
                _ in
                
                self.tableView.reloadData()
            })
            
        } else {
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 6
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            if let inSearchingModeMatches = GameCenterSingleton.sharedInstance.matchDictionary["inSearchingModeMatches"] {
                return inSearchingModeMatches.count
            } else {
                return 0
            }
        case 1:
            if let inInvitationModeMatches = GameCenterSingleton.sharedInstance.matchDictionary["inInvitationModeMatches"] {
                return inInvitationModeMatches.count
            } else {
                return 0
            }
        case 2:
            if let inWaitingForIntivationReplyModeMatches = GameCenterSingleton.sharedInstance.matchDictionary["inWaitingForIntivationReplyModeMatches"] {
                return inWaitingForIntivationReplyModeMatches.count
            } else {
                return 0
            }
        case 3:
            if let localPlayerTurnMatches = GameCenterSingleton.sharedInstance.matchDictionary["localPlayerTurnMatches"] {
                return localPlayerTurnMatches.count
            } else {
                return 0
            }
        case 4:
            if let opponentTurnMatches = GameCenterSingleton.sharedInstance.matchDictionary["opponentTurnMatches"] {
                return opponentTurnMatches.count
            } else {
                return 0
            }
        case 5:
            if let endedMatches = GameCenterSingleton.sharedInstance.matchDictionary["endedMatches"] {
                return endedMatches.count
            } else {
                return 0
            }
        default:
            return 0
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GameCell", forIndexPath: indexPath)
            as! GameCell
        
        switch indexPath.section {
        case 0:
            if let inSearchingModeMatches = GameCenterSingleton.sharedInstance.matchDictionary["inSearchingModeMatches"] {
                cell.match = inSearchingModeMatches[indexPath.row]
                cell.opponentLabel.text = "Random Opponent"
                cell.mode = MatchMode.inSearchingModeMatches
            }
        case 1:
            if let inInvitationModeMatches = GameCenterSingleton.sharedInstance.matchDictionary["inInvitationModeMatches"] {
                cell.match = inInvitationModeMatches[indexPath.row]
                let opponent = GameCenterSingleton.sharedInstance.findParticipantsForMatch(cell.match!)?.opponent
                cell.opponentLabel.text = opponent?.player?.alias
                cell.mode = MatchMode.inInvitationModeMatches
            }
        case 2:
            if let inWaitingForIntivationReplyModeMatches = GameCenterSingleton.sharedInstance.matchDictionary["inWaitingForIntivationReplyModeMatches"] {
                cell.match = inWaitingForIntivationReplyModeMatches[indexPath.row]
                let opponent = GameCenterSingleton.sharedInstance.findParticipantsForMatch(cell.match!)?.opponent
                cell.opponentLabel.text = opponent?.player?.alias
                cell.mode = MatchMode.inWaitingForIntivationReplyModeMatches
            }
        case 3:
            if let localPlayerTurnMatches = GameCenterSingleton.sharedInstance.matchDictionary["localPlayerTurnMatches"] {
                cell.match = localPlayerTurnMatches[indexPath.row]
                let opponent = GameCenterSingleton.sharedInstance.findParticipantsForMatch(cell.match!)?.opponent
                cell.opponentLabel.text = opponent?.player?.alias
                cell.mode = MatchMode.localPlayerTurnMatches
            }
        case 4:
            if let opponentTurnMatches = GameCenterSingleton.sharedInstance.matchDictionary["opponentTurnMatches"] {
                cell.match = opponentTurnMatches[indexPath.row]
                let opponent = GameCenterSingleton.sharedInstance.findParticipantsForMatch(cell.match!)?.opponent
                cell.opponentLabel.text = opponent?.player?.alias
                cell.mode = MatchMode.opponentTurnMatches
            }
        case 5:
            if let endedMatches = GameCenterSingleton.sharedInstance.matchDictionary["endedMatches"] {
                cell.match = endedMatches[indexPath.row]
                let opponent = GameCenterSingleton.sharedInstance.findParticipantsForMatch(cell.match!)?.opponent
                cell.opponentLabel.text = opponent?.player?.alias
                cell.mode = MatchMode.endedMatches
            }
        default:
            break
        }
        
        cell.updateButtons()
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCellWithIdentifier("GameHeaderCell") as! GameHeaderCell
        headerCell.backgroundColor = UIColor.lightGrayColor()
        
        switch (section) {
        case 0:
            headerCell.label.text = "Searching for opponent..."
        case 1:
            headerCell.label.text = "Invited by opponent"
        case 2:
            headerCell.label.text = "Invited opponent & waiting"
        case 3:
            headerCell.label.text = "My turn"
        case 4:
            headerCell.label.text = "Opponent's turn & waiting"
        case 5:
            headerCell.label.text = "Ended matches"
        default:
            headerCell.label.text = "Other"
        }
        
        return headerCell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}