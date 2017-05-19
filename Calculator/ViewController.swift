import UIKit

typealias CalculatorOperation = ((inout CalculatorState, CalculatorButton) -> ());

let operColor = FadingColor.init(
    UIColor.init(red: (180.0 / 255.0), green: (110.0 / 255.0), blue: (254.0 / 255.0), alpha: 1.0),
    UIColor.init(red: (163.0 / 255.0), green: (78.00 / 255.0), blue: (253.0 / 255.0), alpha: 1.0)
);

let funcColor = FadingColor.init(
    UIColor.init(red: (201.0 / 255.0), green: (201.0 / 255.0), blue: (203.0 / 255.0), alpha: 1.0),
    UIColor.init(red: (177.0 / 255.0), green: (178.0 / 255.0), blue: (181.0 / 255.0), alpha: 1.0)
);

let mainColor = FadingColor.init(
    UIColor.init(red: (211.0 / 255.0), green: (212.0 / 255.0), blue: (213.0 / 255.0), alpha: 1.0),
    UIColor.init(red: (190.0 / 255.0), green: (191.0 / 255.0), blue: (193.0 / 255.0), alpha: 1.0)
);

let bgColor = UIColor.init(red: bg, green: bg, blue: bg, alpha: 1.0);
let bg:CGFloat = (32.0 / 255.0);

let numberFunction:CalculatorOperation = { state, button in
    if (state.input == "0") {
        state.input = "";
    }

    if (state.displayResult) {
        state.displayResult = false;
    }

    state.input.append(button.info.label)
};

let operationFunction:((@escaping CalculatorFunction) -> CalculatorOperation) = { op in
    return { state, _ in
        if (!state.displayResult || state.flag) {
            state.bake();
            state.useValue = true;
            state.displayResult = false;
        } else if (state.displayResult) {
            state.useValue = true;
        }

        state.pending = op;
    };
}

let buttons:Array<KeyInfo> = [
    KeyInfo.init( { state, button in
        if (button.label.text == "AC") {
            state.reset();
        } else {
            state.input = "0";

            button.setTitle("AC");
        }
    }, "AC", funcColor),
    KeyInfo.init( { state, _ in
        if (state.input != "0" && state.input != "0.")
        {
            if (state.input.hasPrefix("-")) {
                state.input.remove(at: state.input.startIndex);
            } else {
                state.input = "-" + state.input;
            }
        }
    }, "⁺∕₋", funcColor),
    KeyInfo.init( { state, _ in
        if let current = state.input.characters.index(of: ".") {
            if (current == state.input.characters.index(after: state.input.characters.startIndex)) {
                state.input.remove(at: current);

                let leading = state.input.remove(at: current);
                state.input = ".0" + String.init(leading) + state.input;
            } else {
                state.input.insert(".", at: state.input.index(current, offsetBy: -2));
                state.input.remove(at: state.input.index(after: current));
            }
        } else if (state.input.characters.count >= 2) {
            state.input.insert(".", at: state.input.index(state.input.endIndex, offsetBy: -2));
        } else if (state.input != "0") {
            state.input = "0.0" + state.input;
        }
    }, "%", funcColor),
    KeyInfo.init(operationFunction(/), "÷", operColor), // DIVISION
    KeyInfo.init(numberFunction, "7", mainColor),
    KeyInfo.init(numberFunction, "8", mainColor),
    KeyInfo.init(numberFunction, "9", mainColor),
    KeyInfo.init(operationFunction(*), "×", operColor), // MULTIPLICATION
    KeyInfo.init(numberFunction, "4", mainColor),
    KeyInfo.init(numberFunction, "5", mainColor),
    KeyInfo.init(numberFunction, "6", mainColor),
    KeyInfo.init(operationFunction(-), "-", operColor), // SUBTRACTION
    KeyInfo.init(numberFunction, "1", mainColor),
    KeyInfo.init(numberFunction, "2", mainColor),
    KeyInfo.init(numberFunction, "3", mainColor),
    KeyInfo.init(operationFunction(+), "+", operColor), // ADDITION
    KeyInfo.init( { let _ = ($0.input == "0")        ? () : numberFunction(&$0, $1); }, "0", mainColor),
    KeyInfo.init( { _, _ in }, "E", operColor), // 0 is a large button...
    KeyInfo.init( { let _ = ($0.input.contains(".")) ? () : numberFunction(&$0, $1); }, ".", mainColor),
    KeyInfo.init( { state, _ in state.bake(); }, "=", operColor)
];

struct FadingColor
{
    let main:UIColor;
    let fade:UIColor;

    init(_ mainColor:UIColor, _ fadeColor:UIColor)
    {
        self.fade = fadeColor;
        self.main = mainColor;
    }
}

struct KeyInfo
{
    var operation:CalculatorOperation;
    var color:FadingColor;
    var label:String;

    init(_ operation:@escaping CalculatorOperation, _ label:String, _ color:FadingColor)
    {
        self.operation = operation;
        self.label = label;
        self.color = color;
    }
}

class CalculatorButton : UIView
{
    public private(set) var label:UILabel;
    public var info:KeyInfo;

    public func setTitle(_ newLabel:String) {
        self.label.text = newLabel;
    }

    init(frame:CGRect, info:KeyInfo)
    {
        self.label = UILabel.init();
        self.info = info;

        super.init(frame: frame);
        let color = info.color.main;

        self.label = UILabel.init(frame: CGRect(origin: CGPoint(x: 0, y: 0), size:self.frame.size));
        self.label.textAlignment = NSTextAlignment.center;

        if (color == operColor.main) {
            self.label.font = UIFont.systemFont(ofSize: 50.0, weight: UIFontWeightThin);
            self.label.textColor = UIColor.white;
        } else if (color == funcColor.main) {
            self.label.font = UIFont.systemFont(ofSize: 32.0, weight: UIFontWeightThin);
        } else {
            self.label.font = UIFont.systemFont(ofSize: 40.0, weight: UIFontWeightThin);
        }

        self.backgroundColor = color;
        self.addSubview(self.label);
        self.setTitle(info.label);
    }

    required init?(coder aDecoder: NSCoder) {
        return nil;
    }
}

class ViewController : UIViewController
{
    override var preferredStatusBarStyle:UIStatusBarStyle {
        get {
            return UIStatusBarStyle.lightContent;
        }
    }

    var state:CalculatorState = CalculatorState.init();
    var clearLabel:UILabel = UILabel.init();
    var label:UILabel = UILabel.init();

    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.view.backgroundColor = bgColor;

        let buttonSideLength = (UIScreen.main.bounds.size.width - 9) / 4;
        let zeroSize = CGSize(width: ((buttonSideLength * 2) + 1), height: buttonSideLength);
        let buttonSize = CGSize(width: buttonSideLength, height: buttonSideLength);

        var position = CGPoint(x: 3, y: UIScreen.main.bounds.size.height - ((buttonSideLength * 5) + 10));
        var labelPosition = CGPoint(x: 20, y: UIApplication.shared.statusBarFrame.size.height);
        let labelHeight = (position.y - labelPosition.y);
        labelPosition.y += labelHeight / 3.0;

        let labelSize = CGSize(width: UIScreen.main.bounds.size.width - 40, height: labelHeight * (2.0 / 3.0));
        label = UILabel.init(frame: CGRect(origin: labelPosition, size: labelSize));
        label.font = UIFont.systemFont(ofSize: 100.0, weight: UIFontWeightUltraLight);
        label.textAlignment = NSTextAlignment.right;
        label.textColor = UIColor.white;
        label.adjustsFontSizeToFitWidth = true;
        label.minimumScaleFactor = 35.0 / label.font.pointSize;
        label.lineBreakMode = NSLineBreakMode.byTruncatingMiddle;
        label.numberOfLines = 1;
        label.text = state.input;

        for y in 0..<5
        {
            position.x = 3;

            for x in 0..<4
            {
                let zero = (x == 0 && y == 4);

                if (x == 1 && y == 4) {
                    continue;
                }

                let frame = CGRect(origin: position, size: (zero ? zeroSize : buttonSize));
                let button = CalculatorButton(frame: frame, info: buttons[(y * 4) + x]);
                self.view.addSubview(button);

                if (x == 0 && y == 0) {
                    self.clearLabel = button.label;
                }

                let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)));
                button.addGestureRecognizer(tapRecognizer);

                position.x += (zero ? zeroSize.width : buttonSideLength) + 1;
            }

            position.y += buttonSideLength + 1;
        }

        self.view.addSubview(self.label);
    }

    public func onTap(_ recognizer:UIGestureRecognizer) {
        let button = recognizer.view! as! CalculatorButton;

        UIView.animate(withDuration: 0.075, animations: {
            button.backgroundColor = button.info.color.fade;
        }) { _ in
            UIView.animate(withDuration: 0.075, animations: {
                button.backgroundColor = button.info.color.main;
            });
        }

        button.info.operation(&self.state, button);

        if (state.input != "0") {
            self.clearLabel.text = "C";
        }

        if (state.input.hasPrefix(".")) {
            state.input = "0" + state.input;
        } else if (state.input.hasPrefix("-.")) {
            state.input.remove(at: state.input.startIndex);
            state.input = "-0" + state.input;
        }

        if (state.displayResult) {
            label.text = String.init(state.value);
        } else {
            label.text = state.input;
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()

        // OH NO WE GOT A MEMORY WARNING!!!!!
        // Oh wait this like never happens...
        // Also, I don't care.
    }
}
