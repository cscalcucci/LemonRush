//
//  ViewController.swift
//  LemonRush
//
//  Created by Christopher Scalcucci on 11/5/15.
//  Copyright © 2015 Christopher Scalcucci. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var toggleMenuBtn: UIButton!

    @IBOutlet weak var lemonCount: UILabel!
    @IBOutlet weak var lemonadeCount: UILabel!
    @IBOutlet weak var salesCount: UILabel!

    @IBOutlet weak var dollarsButton: UIButton!

    @IBOutlet weak var salesView: UIView!
    @IBOutlet weak var workersView: UIView!
    @IBOutlet weak var productView: UIView!
    @IBOutlet weak var buildingView: UIView!
    @IBOutlet weak var shopView: UIView!

    @IBOutlet weak var currentPriceLabel: UILabel!

    @IBOutlet weak var tableView: UITableView!

    var animator: UIDynamicAnimator!
    var isOpen = false

    var lemons = 0
    var lemonades = 0

    var salesMade = 0
    var dollars = 0

    var player : Player!
    var store : Store!

    var lemonRate : Upgrade!
    var lemonadeRate : Upgrade!
    var lemonadePrice : Upgrade!

    var salesArray : [Upgrade] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        lemonRate = Upgrade(type: Type.LemonRate, price: 50, rank: 0, increaseValue: 1)
        lemonadeRate = Upgrade(type: Type.LemonadeRate, price: 50, rank: 0, increaseValue: 1)
        lemonadePrice = Upgrade(type: Type.LemonadePrice, price: 100, rank: 0, increaseValue: 5)

        salesArray += [lemonRate, lemonadeRate, lemonadePrice]

        player = Player(name: "Default")
        store = Store(player: player)

        animator = UIDynamicAnimator(referenceView: view)

        NSNotificationCenter.defaultCenter().addObserverForName("Price Changed", object: nil, queue: nil) { note in

            self.currentPriceLabel.text = "Lemonade Price: $\(self.store.lemonadePrice)"

        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var cell : UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("salesCell")! as UITableViewCell

        let upgrade = salesArray[indexPath.row]

        cell.textLabel!.text = upgrade.type.rawValue
        cell.detailTextLabel!.text = upgrade.subtitle()

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {

            let upgrade : Upgrade = self.salesArray[indexPath.row]

            if self.player.dollars >= upgrade.price {
                self.store.upgrade(upgrade)

                dispatch_async(dispatch_get_main_queue()) {

                    self.dollarsButton.setTitle("$\(self.player.dollars)", forState: .Normal)
                    self.currentPriceLabel.text = "Lemonade Price: $\(self.store.lemonadePrice)"
                }

            } else {

                let alertController = UIAlertController(title: "Error: You're Poor!", message: "Sell more lemonade to purchase this upgrade.", preferredStyle: .Alert)

                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                    // ...
                }
                alertController.addAction(OKAction)
                
                self.presentViewController(alertController, animated: true) {
                }
            }

        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return salesArray.count
    }

    @IBAction func increaseItem(sender: UIButton) {
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {

            switch sender.tag {
                case 0:
                    self.store.buyLemon()
                    break
                default:
                    if self.store.lemons >= self.store.lemonadeTapRate {
                        self.store.makeLemonade()
                    }
                    break
            }

            dispatch_async(dispatch_get_main_queue()) {

                self.lemonCount.text = "\(self.store.lemons)"
                self.lemonadeCount.text = "\(self.store.lemonades)"
            }
        }
    }

    @IBAction func menuTabbed(sender: UIButton) {

        var index = 0

        for tab in [salesView, workersView, productView, buildingView, shopView] {

            if sender.tag == index {
                tab.hidden = false
            } else {
                tab.hidden = true
            }

            index++
        }
    }

    @IBAction func sellLemonade(sender: UIButton) {
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {

            if self.store.lemonades > 0 {
                self.store.sellLemonade(1)
            }

//            let dollarText = self.dollarString(self.dollars)

            dispatch_async(dispatch_get_main_queue()) {
                self.salesCount.text = "Sales: \(self.store.lemonadeSold)"
                self.dollarsButton.setTitle("$\(self.player.dollars)", forState: .Normal)
                self.lemonadeCount.text = "\(self.store.lemonades)"
            }
        }
    }


    @IBAction func menuToggled(sender: UIButton) {
        showBasePanel(isOpen)
        isOpen = !isOpen

    }

    func dollarString(amount: Float) -> String {

        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle

        return formatter.stringFromNumber(amount)!
    }

    func showBasePanel(open:Bool) {

        animator.removeAllBehaviors()

        // Define constants to be plugged into animator
        let gravityY : CGFloat  = (open) ? 3.5 : -3.5
        let statusString = (open) ? "Open" : "Close"
        self.toggleMenuBtn.setTitle(statusString, forState: .Normal)

        //Defines two barriers to restrict the menu when acted upon by gravity
        let upperBarrier = UIView(frame: CGRect(x: 0, y: view.frame.height - menuView.frame.height, width: view.frame.width, height: 1))
        let lowerBarrier = UIView(frame: CGRect(x: 0, y: view.frame.height + (menuView.frame.height - 50), width: view.frame.width, height: 1))

        view.addSubview(upperBarrier)
        view.addSubview(lowerBarrier)

        // animator behaviours
        let gravityBehavior = UIGravityBehavior(items: [menuView, upperBarrier, lowerBarrier])
        let collisionBehavior = UICollisionBehavior(items:[menuView, upperBarrier, lowerBarrier])
        let panelBehavior = UIDynamicItemBehavior(items:[menuView, upperBarrier, lowerBarrier])

        // Set the behvaiours
        panelBehavior.allowsRotation = false
        panelBehavior.elasticity = 0

        // Set collision behaviours
        collisionBehavior.addBoundaryWithIdentifier("upper", forPath: UIBezierPath(rect: upperBarrier.frame))
        collisionBehavior.addBoundaryWithIdentifier("lower", forPath: UIBezierPath(rect: lowerBarrier.frame))
        gravityBehavior.gravityDirection = CGVectorMake(0, gravityY)

        // set the animator behvaiours
        animator.addBehavior(gravityBehavior)
        animator.addBehavior(panelBehavior)
        animator.addBehavior(collisionBehavior)

    }

}

class Upgrade {

    let type : Type!

    var rank : Int!
    var price : Int!

    var increaseValue: Int!

    init(type: Type, price: Int, rank: Int, increaseValue: Int) {
        self.type = type
        self.rank = rank
        self.price = price
        self.increaseValue = increaseValue
    }

    func subtitle() -> String {

        let type : Type = self.type

        switch type {
            case .LemonRate : return "Increase lemons per tap by \(self.increaseValue) Cost: \(price)"
            case .LemonadeRate : return "Increase lemonades per tap by \(self.increaseValue) Cost: \(price)"
            case .LemonadePrice : return "Increase lemonade price by $ \(self.increaseValue)  Cost: \(price)"
        }
    }

}

enum Type : String {
    case LemonRate = "Lemon Rate"
    case LemonadeRate = "Lemonade Rate"
    case LemonadePrice = "Lemonade Price"
}




class Player {

    var dollars : Int = 0
    var gold : Int = 20

    var username : String!

    init(name: String) {
        self.username = name

    }
}

class Store {

    var lemons = 0
    var lemonades = 0

    var lemonTapRate = 1
    var lemonadeTapRate = 1
    var lemonadePrice = 5 {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName("Price Changed", object: nil)

        }
    }

    var lemonsPurchased = 0
    var lemonadeMade = 0
    var lemonadeSold = 0

    var lemonistas = 0
    var lemonators = 0

    var player : Player!

    init(player: Player) {
        self.player = player


    }

    func buyLemon() {
        self.lemons += self.lemonTapRate
    }

    func makeLemonade() {
        self.lemons -= self.lemonadeTapRate
        self.lemonades += self.lemonadeTapRate
    }

    func sellLemonade(amount: Int) {
        self.lemonades -= amount
        self.lemonadeSold += amount
        self.player.dollars += (lemonadePrice * amount)
    }

    func upgrade(upgrade: Upgrade) {

        let type : Type = upgrade.type

        self.player.dollars -= upgrade.price

        switch type {
            case .LemonRate : lemonTapRate += upgrade.increaseValue; break
            case .LemonadeRate : lemonadeTapRate += upgrade.increaseValue; break
            case .LemonadePrice : lemonadePrice += upgrade.increaseValue; break
        }
    }





}

