//
//  ViewController.swift
//  LemonRush
//
//  Created by Christopher Scalcucci on 11/5/15.
//  Copyright © 2015 Christopher Scalcucci. All rights reserved.
//

import UIKit
import Spring

class ViewController: UIViewController {

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


    var animator: UIDynamicAnimator!
    var isOpen = false

    var lemons = 0
    var lemonades = 0
    var lemonadePrice = 5

    var salesMade = 0
    var dollars = 0


    override func viewDidLoad() {
        super.viewDidLoad()


        animator = UIDynamicAnimator(referenceView: view)
    }

    @IBAction func increaseItem(sender: UIButton) {
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {

            switch sender.tag {
                case 0:
                    self.lemons++
                    break
                default:
                    if self.lemons > 0 {
                        self.lemons--
                        self.lemonades++
                    }
                    break
            }

            dispatch_async(dispatch_get_main_queue()) {

                self.lemonCount.text = "\(self.lemons)"
                self.lemonadeCount.text = "\(self.lemonades)"
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

            if self.lemonades > 0 {
                self.lemonades--
                self.salesMade++
                self.dollars += self.lemonadePrice
            }

//            let dollarText = self.dollarString(self.dollars)

            dispatch_async(dispatch_get_main_queue()) {
                self.salesCount.text = "Sales: \(self.salesMade)"
                self.dollarsButton.setTitle("$\(self.dollars)", forState: .Normal)
                self.lemonadeCount.text = "\(self.lemonades)"
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

