//
//  ContentView.swift
//  Calculator
//
//  Created by Dylan McIntyre on 5/6/25.
//

import SwiftUI

struct ContentView: View {
    
    // VARIABLES
    
    @State private var equation: String = "0"
    private let digits: Regex = /[0-9]/
    private let ops: Regex = /[*+-]/
    
    // VIEWS

    var body: some View {
        VStack {
            equationView
            
            numberView
        }
    }
    
    private var equationView: some View {
        HStack {
            Text(equation)
                .font(.title)
                .foregroundColor(.white)
                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                .background(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            calcButton("AC")
        }
    }
    
    private var numberView: some View {
        VStack {
            threeRowView("7", "8", "9")
            
            fourRowView("4", "5", "6", "*")
            
            fourRowView("1", "2", "3", "-")
            
            fourRowView("0", "<-", "=", "+")
        }
    }
    
    // FUNCTIONS
    
    /** Return a view for a row with a single button */
    private func oneRowView(_ button: String) -> some View {
        HStack {
            calcButton(button)
        }
    }
    
    /** Return a view for a row with three buttons */
    private func threeRowView(_ button1: String, _ button2: String, _ button3: String) -> some View {
        HStack {
            calcButton(button1)
            
            calcButton(button2)
            
            calcButton(button3)
        }
    }
    
    /** Return a view for a row with four buttons */
    private func fourRowView(_ button1: String, _ button2: String, _ button3: String, _ button4: String) -> some View {
        HStack {
            calcButton(button1)
            
            calcButton(button2)
            
            calcButton(button3)
            
            calcButton(button4)
        }
    }
    
    /** Return a calculator button corresponding to a given value */
    private func calcButton(_ val: String) -> Button<some View> {
        return Button {
            // If digit button pressed, add digit to equation
            if (val.contains(digits)) {
                if (equation != "0") {
                    equation += val
                }
                // Don't add 0 to empty equation
                else {
                    equation = val
                }
            }
            // If back button pressed, remove most recent value from nonzero equation
            else if (val == "<-" && equation != "0") {
                // A single digit equation should just become 0
                if (equation.count == 1) {
                    equation = "0"
                }
                else {
                    equation.removeLast()
                }
            }
            // If clear button pressed, equation becomes empty
            else if (val == "AC") {
                equation = "0"
            }
            // If operation button pressed, add operation to equation
            else if (val.contains(ops)) {
                // Operations cannot be added consecutively
                if (!equation.suffix(1).contains(ops)) {
                    equation += val
                }
            }
            // If equation button pressed and current equation is valid, solve equation
            else if (val == "=" && !equation.suffix(1).contains(ops)) {
                equation = solveEquation(equation)
            }
        } label: {
            // Display original value for non-back button
            if (val != "<-") {
                Text(val)
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            // Display the delete SF Symbol for back button
            else {
                Image(systemName: "delete.left")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
        }
    }
    
    /**
     Return the solution to a given mathematical equation (the equation must have a valid format)
     */
    private func solveEquation(_ eq: String) -> String {
        var answer: Int = 0
        var newEq: String = eq
        
        // Order of operations: do multiplication first
        while (newEq.contains("*")) {
            // Split equation
            let multIndex: String.Index = newEq.firstIndex(of: "*") ?? newEq.endIndex
            
            var multPreString: String = String(newEq[..<multIndex])
            var multPostString: String = String(newEq.suffix(from: multIndex))
            
            // Parse first number
            // Remove any leading negative sign
            if (multPreString.first == "-") {
                multPreString.removeFirst()
            }
            var temp1: String = multPreString
            // Trim everything to the left of the last number
            if let match: Regex.Match = multPreString.matches(of: ops).last {
                temp1 = String(multPreString.suffix(from: multPreString.index(after: match.startIndex)))
            }
            
            // Parse second number
            // Remove multiplication sign
            multPostString.removeFirst()
            var temp2: String = multPostString
            // Trim everything to the right of the first number
            if let match: Regex.Match = multPostString.firstMatch(of: ops) {
                temp2 = String(multPostString.prefix(upTo: match.startIndex))
            }
            
            // Number conversion
            let num1: Int = Int(temp1) ?? 0
            // Trigger overflow if number is too large or otherwise can't be converted
            if (num1 == 0 && temp1 != "0") {
                return "Overflow!"
            }
            
            // Number conversion
            let num2: Int = Int(temp2) ?? 0
            // Trigger overflow if number is too large or otherwise can't be converted
            if (num2 == 0 && temp2 != "0") {
                return "Overflow!"
            }
            
            // Trigger overflow if multiplication would result in answer being too small/large
            if (Int.max / num1 < abs(num2)) {
                return "Overflow!"
            }
            else {
                let num: Int = num1 * num2
                // Replace numbers with their product in the original equation
                newEq.replaceSubrange(newEq.index(multIndex, offsetBy: -temp1.count)...newEq.index(multIndex, offsetBy: temp2.count), with: String(num))
            }
        }
        
        // Evaluate initial negative sign, if any
        var negative: Bool = false
        if (newEq.hasPrefix("-")) {
            newEq.removeFirst()
            negative = true
        }
        
        // Parse first number
        var addIndex: String.Index = newEq.firstIndex(of: "+") ?? newEq.endIndex
        var subIndex: String.Index = newEq.firstIndex(of: "-") ?? newEq.endIndex
        
        var addString: String = String(newEq[..<addIndex])
        var subString: String = String(newEq[..<subIndex])
        var temp: String = subString
        if (subString.contains(ops)) {
            temp = addString
        }
        
        // Number conversion
        var num: Int = Int(temp) ?? 0
        // Trigger overflow if number is too large or otherwise can't be converted
        if (num == 0 && temp != "0") {
            return "Overflow!"
        }
        else {
            answer = num
            if (negative) {
                answer *= -1
            }
        }
        
        // Trim number from equation
        newEq.removeFirst(temp.count)
        
        // Repeat until equation is empty
        while (!newEq.isEmpty) {
            // Identify operation
            let op: Character = newEq.removeFirst()
            
            // Parse number
            addIndex = newEq.firstIndex(of: "+") ?? newEq.endIndex
            subIndex = newEq.firstIndex(of: "-") ?? newEq.endIndex
            
            addString = String(newEq[..<addIndex])
            subString = String(newEq[..<subIndex])
            temp = subString
            if (subString.contains(ops)) {
                temp = addString
            }
            
            // Number conversion
            num = Int(temp) ?? 0
            // Trigger overflow if number is too large or otherwise can't be converted
            if (num == 0 && temp != "0") {
                return "Overflow!"
            }
            // Process addition
            if (op == "+") {
                // Trigger overflow if addition would result in answer being too large
                if (Int.max - num < answer) {
                    return "Overflow!"
                }
                else {
                    answer += num
                }
            }
            // Process subtraction
            else if (op == "-") {
                // Trigger overflow if subtraction would result in answer being too small
                if (Int.min + num > answer) {
                    return "Overflow!"
                }
                else {
                    answer -= num
                }
            }
            // Nonsense operation (if this happens, something went wrong!)
            else {
                return "???"
            }
            
            // Trim number from equation
            newEq.removeFirst(temp.count)
        }
        return String(answer)
    }
}

#Preview {
    ContentView()
}
