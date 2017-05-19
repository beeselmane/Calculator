import Foundation

typealias CalculatorFunction = ((Double, Double) -> (Double));

struct CalculatorState {
    var pending:CalculatorFunction? = nil;

    var value:Double = 0.0;
    var input:String = "0";

    var displayResult:Bool = false;
    var useValue:Bool = false;
    var flag:Bool = true;

    mutating func bake() {
        if (!self.useValue && self.input != "0") {
            self.value = Double.init(self.input)!;
        } else {
            if (self.pending == nil) {
                return;
            }

            self.value = self.pending!(self.value, Double.init(self.input)!);
            self.pending = nil;
        }

        self.displayResult = true;
        self.useValue = false;
        self.flag = false;
        self.input = "0";
    }

    mutating func reset() {
        self.pending = nil;

        self.input = "0";
        self.value = 0;

        self.displayResult = false;
        self.useValue = false;
        self.flag = true;
    }
}
