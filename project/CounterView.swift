//
//  CounterView.swift
//  project
//
//  Created by Анастасия Сергеева on 16.01.2024.
//

import SwiftUI

struct ConsumedCalories: Codable, Hashable {
    var count: Int
    var proteins: Int
    var fats: Int
    var carbohydrates: Int
}

class Calories: ObservableObject {
    @Published var consumed: ConsumedCalories {
        didSet {
            saveConsumed()
        }
    }
    @Published var spent: Int {
        didSet {
            saveSpent()
        }
    }

    init() {
        if let savedConsumed = UserDefaults.standard.data(forKey: "consumedCalories"), let savedSpent = UserDefaults.standard.data(forKey: "spentCalories") {
            let decoder = JSONDecoder()
            if let loadedConsumed = try? decoder.decode(ConsumedCalories.self, from: savedConsumed),
               let loadedSpent = try? decoder.decode(Int.self, from: savedSpent) {
                consumed = loadedConsumed
                spent = loadedSpent
                return
            }
        }
        
        consumed = ConsumedCalories(count: 0, proteins: 0, fats: 0, carbohydrates: 0)
        spent = 0
    }

    func saveConsumed() {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(consumed) {
            UserDefaults.standard.set(encodedData, forKey: "consumedCalories")
        }
    }
    
    func saveSpent() {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(spent) {
            UserDefaults.standard.set(encodedData, forKey: "spentCalories")
        }
    }
}

struct Meal: Codable, Hashable {
    var name: String
    var calories: ConsumedCalories
}

class Meals: ObservableObject {
    @Published var list: [Meal]
    
    init() {
        list = [
            Meal(name: "ФЫФЫ", calories: ConsumedCalories(count: 100, proteins: 1, fats: 1, carbohydrates: 1)),
            Meal(name: "Aldldf", calories: ConsumedCalories(count: 100, proteins: 1, fats: 1, carbohydrates: 1)),
            Meal(name: "Asfdf", calories: ConsumedCalories(count: 100, proteins: 1, fats: 1, carbohydrates: 1)),
            Meal(name: "effeA", calories: ConsumedCalories(count: 100, proteins: 1, fats: 1, carbohydrates: 1))
            ]
    }

}

struct CounterView: View {
    @ObservedObject var calories = Calories()
    @AppStorage("recommend") private var recommend: Bool = true
    @State private var isAddingCalories = false
    var body: some View {
        VStack {
            VStack {
                HStack {
                    VStack {
                        Text("Потреблено:   \(calories.consumed.count) ккал")
                            .padding(.bottom)
                            .padding(.trailing)
                        HStack {
                            VStack(alignment: .leading) {
                                Text("      Белки:  ")
                                Text("      Жиры:  ")
                                Text("      Углеводы:  ")
                            }
                            VStack(alignment: .trailing) {
                                Text("\(calories.consumed.proteins) гр")
                                Text("\(calories.consumed.fats) гр")
                                Text("   \(calories.consumed.carbohydrates) гр")
                            }
                        }
                    }
                    Button(action: {
                        isAddingCalories = true
                    }, label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color(hex: "#0CA2AF"))
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                            .padding()
                    })
                    .padding()
                }
                .padding()
                .sheet(isPresented: $isAddingCalories, content: {
                    AddCaloriesView(calories: calories)
                })
            }
            .frame(minWidth: 300)
            .background(.blue)
            
            VStack {
                Text("Потрачено")
                HStack {
                    VStack {
                        Text("F")
                        Text("A")
                    }
                    VStack {
                        Text("D")
                        Text("B")
                    }
                }
            }
            .frame(minWidth: 300)
            .background(.orange)
            
            VStack {
                
            }
        }
    }
}

struct AddCaloriesView: View {
    @ObservedObject var calories = Calories()
    @State private var searchText : String = ""
    @ObservedObject var meals = Meals()
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    TextField("Начните вводить название", text: $searchText)
                        .padding()
                        .background(.blue)
                }
                .frame(minWidth: 200)
                .cornerRadius(5)
                .padding()
                VStack {
                    ForEach(meals.list, id: \.self) { item in
                        if searchText.contains(item.name) {
                            VStack {
                                HStack {
                                    Text(item.name)
                                    Button(action: {
                                        addToCounter(meal: item)
                                    }, label: {
                                        Text("Добавить")
                                    })
                                }
                            }
                        }
                    }/***/
                }
                .padding()
                VStack {
                    Text("Не нашли то, что хотели?")
                    NavigationLink(destination: AddMealView()) { Text("Добавьте своё!")
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
    
    func addToCounter(meal: Meal) {
        calories.consumed.count += meal.calories.count
        calories.consumed.fats += meal.calories.fats
        calories.consumed.proteins += meal.calories.proteins
        calories.consumed.carbohydrates += meal.calories.carbohydrates
        
        print("CALORIES: ", calories.consumed)
    }
}

struct AddMealView: View {
    @State private var name: String = ""
    @State private var count: String = ""
    @State private var proteins: String = ""
    @State private var fats: String = ""
    @State private var carbohydrates: String = ""
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack {
            NavigationView {
                Form {
                    Section(header: Text("Добавьте блюдо")) {
                        TextField("Введите название", text: $name)
                        //.padding()
                    }
                    Section(header: Text("Добавьте количество ккал на 1 порцию")) {
                        TextField("Введите количество ккал", text: $count)
                            .keyboardType(.numberPad)

                    }
                    Section(header: Text("Добавьте массу белков на 1 порцию")) {
                        TextField("Введите массу", text: $proteins)
                            .keyboardType(.numberPad)

                    }
                    Section(header: Text("Добавьте массу жиров на 1 порцию")) {
                        TextField("Введите массу", text: $fats)
                            .keyboardType(.numberPad)

                    }
                    Section(header: Text("Добавьте массу углеводов на 1 порцию")) {
                        TextField("Введите массу", text: $carbohydrates)
                            .keyboardType(.numberPad)

                    }
                }
            }
            .navigationBarItems(
                trailing: Button("Добавить") {
                    if name != "" {
                        print("")
                    }
                    
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

#Preview {
    CounterView()
}
