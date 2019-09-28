//
//  ViewController.swift
//  TestNameClassification
//
//  Created by izuru nomura on 2019/09/08.
//  Copyright © 2019 izuru nomura. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController {
    
    let classification_model = classification()
    let classDic: [Int64 : String] = [
        0: "Czech",
        1: "German",
        2: "Arabic",
        3: "Japanese",
        4: "Chinese",
        5: "Vietnamese",
        6: "Russian",
        7: "French",
        8: "Irish",
        9: "English",
        10: "Spanish",
        11: "Greek",
        12: "Italian",
        13: "Portiguese",
        14: "Scottish",
        15: "Dutch",
        16: "Korean",
        17: "Polish"
    ]
    let all_letters:String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ .,;'-"
    let hidden_size:Int = 128
//    var n_letter:Int
    
    @IBOutlet weak var input: UITextField!
    @IBOutlet weak var result_1: UITextField!
    @IBOutlet weak var result_2: UITextField!
    @IBOutlet weak var result_3: UITextField!
    @IBOutlet weak var result_num_1: UITextField!
    @IBOutlet weak var result_num_2: UITextField!
    @IBOutlet weak var result_num_3: UITextField!
    
    @IBAction func execClassification(_ sender: Any) {
        // execute classification.
        let _name: String? = input.text;
        guard let name:String = _name else {
            print("this is nil");
            return;
        }
        
        // validate string
        if ( !validateString(string: name) ) {
            return;
        }
        
        // make input One Hot Vector
        let ml_input_array: [MLMultiArray] = convertStringToOneHotVector( string: name );
        
        // init hidden vector
        let ns_hidden_size: NSNumber = hidden_size as NSNumber;
        let ml_hidden = try! MLMultiArray(shape: [ns_hidden_size], dataType: MLMultiArrayDataType.float32);
        initEmptyVector(vector: ml_hidden, size: hidden_size);
        
        // predict
        predictNameLanguage( string: name, input: ml_input_array, hidden: ml_hidden);
    }
    
    // validate input value
    func validateString( string : String! ) -> Bool {
        for name_letter in string {
            var exist:Bool = false;
            for right_letter in all_letters {
                if ( name_letter == right_letter ) {
                    exist = true;
                    break;
                }
            }
            if( exist == false ) {
                print("not correct letter in sentence!");
                return false;
            }
        }
        return true;
    }
    
    // convert input name to one hot vector
    func convertStringToOneHotVector( string : String! ) -> [MLMultiArray] {
        var one_hot_vectors: [MLMultiArray] = [];
        
        var name_counter = 0;
        var letter_counter = 0;

        let n_letter = all_letters.count;
        let ns_n_letter: NSNumber = n_letter as NSNumber;

        
        for string in string {
            // define ml multi array by one word
            let ml_input = try! MLMultiArray(shape: [ns_n_letter], dataType: MLMultiArrayDataType.float32);
            letter_counter = 0;
            for letter in all_letters {
                if ( string == letter ) {
                    ml_input[letter_counter] = 1;
                } else {
                    ml_input[letter_counter] = 0;
                }
                letter_counter+=1;
            }
            one_hot_vectors.append(ml_input);
            name_counter+=1;
        }
        
        return one_hot_vectors;
    }
    
    // initialize vector as empty vector
    func initEmptyVector( vector: MLMultiArray, size: Int ) {
        for i in 0 ... size - 1 {
            vector[i] = 0;
        }
    }
    
    // predict what language input name is
    func predictNameLanguage( string: String, input: [MLMultiArray], hidden: MLMultiArray) {
        var output_array: [Int64: Double] = [:];
        let n_string = string.count;
        var ml_hidden: MLMultiArray = hidden;
        
        for i in 0 ... n_string - 1 {
            if let output = try? self.classification_model.prediction(_0: input[i], _1: ml_hidden) {
                ml_hidden = output._7;
                output_array = output._9;
            }
        }
        
        // sort result
        let output_sorted_array = output_array.sorted{ $0.value > $1.value }
        
        print(output_array);
        print(ml_hidden);
        
        dispResult(array: output_sorted_array);
    }
    
    // display result
    func dispResult( array: [(key: Int64, value: Double)] ) {
        result_1.text = classDic[array[0].key] as! String;
        result_2.text = classDic[array[1].key] as! String;
        result_3.text = classDic[array[2].key] as! String;
        result_num_1.text = String("\(round(array[0].value*1000)/1000)");
        result_num_2.text = String("\(round(array[1].value*1000)/1000)");
        result_num_3.text = String("\(round(array[2].value*1000)/1000)");
    }
    
    @IBAction func Reset(_ sender: Any) {
        input.text = "";
        result_1.text = "";
        result_2.text = "";
        result_3.text = "";
        result_num_1.text = "";
        result_num_2.text = "";
        result_num_3.text = "";
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

