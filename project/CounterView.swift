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
            Meal(name: "Гречневая каша", calories: ConsumedCalories(count: 158, proteins: 5, fats: 1, carbohydrates: 30)),
            Meal(name: "Макароны", calories: ConsumedCalories(count: 200, proteins: 6, fats: 4, carbohydrates: 35)),
            Meal(name: "Рис", calories: ConsumedCalories(count: 176, proteins: 5, fats: 1, carbohydrates: 38)),
            Meal(name: "Курица в духовке", calories: ConsumedCalories(count: 190, proteins: 29, fats: 7, carbohydrates: 0)),
            Meal(name: "Курица отварная", calories: ConsumedCalories(count: 85, proteins: 13, fats: 4, carbohydrates: 0)),
            Meal(name: "Курица жареная", calories: ConsumedCalories(count: 337, proteins: 36, fats: 19, carbohydrates: 0)),
            Meal(name: "Индейка в духовке", calories: ConsumedCalories(count: 255, proteins: 44, fats: 8, carbohydrates: 0)),
            Meal(name: "Индейка отварная", calories: ConsumedCalories(count: 202, proteins: 35, fats: 6, carbohydrates: 1)),
            Meal(name: "Индейка жареная", calories: ConsumedCalories(count: 196, proteins: 26, fats: 10, carbohydrates: 0)),
            Meal(name: "Чай черный с сахаром (2 л.)", calories: ConsumedCalories(count: 21, proteins: 0, fats: 0, carbohydrates: 5)),
            Meal(name: "Чай черный без сахара", calories: ConsumedCalories(count: 0, proteins: 0, fats: 0, carbohydrates: 0)),
            Meal(name: "Яйцо куриное варёное", calories: ConsumedCalories(count: 84, proteins: 7, fats: 6, carbohydrates: 1))
            ]
    }

}

struct CounterView: View {
    @ObservedObject var calories = Calories()
    @AppStorage("recommend") private var recommend: Bool = true
    @State private var isAddingCalories = false
    @State private var progress: Float = 0.5
    @State private var spentCalories2: Int = 0
    
    var n = Int.random(in: 0...30000)
    var k = 0.035 //количество калорий, сжигаемых за 1 шаг на 1 кг веса
    
    var body: some View {
        VStack {
            VStack {
                Button(action: {
                    isAddingCalories = true
                }, label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(hex: "#0CA2AF"))
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        .padding()
                })
                Text("Потреблено:   \(calories.consumed.count) ккал")
                    .padding(.bottom)
                    .padding(.trailing)
                HStack {
                    VStack {
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
                        .padding(.bottom)
                    }
                }
                //.padding()
                .sheet(isPresented: $isAddingCalories, content: {
                    AddCaloriesView(calories: calories)
                })
            }
            .frame(minWidth: 300)
            .background(Color(hex: "#d7e5fc"))
            .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
            .cornerRadius(10)
            
            VStack {
                Text("Потрачено")
                    .padding(.top)
                HStack {
                    VStack {
                        Image(systemName: "dumbbell.fill")
                        Text("A")
                    }
                    
                    VStack {
                        Image(systemName: "shoeprints.fill")
                        Text("\(spentCalories2)")
                    }
                }
                .padding()
            }
            .frame(minWidth: 300)
            .background(Color(hex: "#d7e5fc"))
            .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
            .cornerRadius(10)
            
            VStack {
                Text("Пройдено сегодня:")
                    .padding(.top)
                Text("\(n)")
                ProgressBar(progress: $progress)
                    .frame(width: 200, height: 20)
                    .padding()
            }
            .frame(minWidth: 300)
            .background(Color(hex: "#d7e5fc"))
            .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
            .cornerRadius(10)
            
            if recommend {
                VStack {
                    RecommendView()
                }
                .frame(maxWidth: 300)
                .padding()
                .background(Color(hex: "#f0dbff"))
                .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                .cornerRadius(10)
            }
        }
        .onAppear {
            progress = Float((100 * n) / 10000) / 100.0
            if progress > 1.0 {
                progress = 1.0
            }

            spentCalories2 = Int(k * Double(n))
        }
    }
}

struct ProgressBar: View {
    @Binding var progress: Float
    @State var col: String = "#424bf5"

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    //.opacity(0.8)
                    .foregroundColor(Color(hex: "#FFFFFF"))

                Rectangle()
                    .frame(width: min(CGFloat(self.progress) * geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color(hex: col))
                    .animation(.linear)
            }
            .onAppear {
                if progress == 1.0 {
                    col = "#249131"
                }
            }
            .cornerRadius(5.0)
        }
    }
}
/*
struct DayMenu: Codable, Hashable {
    var day: String
    var menu: [String]
}

class RecommendMenu {
    var menu: [DayMenu]
    
    init() {
        menu = [
        DayMenu(day: "Пн", menu: ["творожная масса с изюмом", "гарнир из гречки с курицей", "морковный салат"]),
        DayMenu(day: "Вт", menu: ["кусок хлеба, одно яйцо", "перец, тушенный с кабачками и баклажанами", "отварное куриное мясо"]),
        DayMenu(day: "Ср", menu: ["творожная масса", "щи или другой суп из овощей", "кабачки, тушенные с морковью и болгарским перцем"]),
        DayMenu(day: "Чт", menu: ["булка из муки с отрубями и творожным сыром", "нарезанные свежие овощи", "вареное яйцо"]),
        DayMenu(day: "Пт", menu: ["яйцо с помидорами", "свекольник", "отварная говядина"]),
        DayMenu(day: "Сб", menu: ["овсяная каша на молоке", "гарнир из крупы с куриным филе", "салат из морской капусты или других морепродуктов"]),
        DayMenu(day: "Вс", menu: ["сырники", "овощной гарнир с рыбой", "нарезанные сезонные фрукты"])
        ]
    }
}
*/

struct RecommendView: View {
    var texts: [String] = [
        "1. Исключите из своего ежедневного рациона магазинные десерты и выпечку с большим содержанием белого сахара и пшеничной муки. Это поможет убрать из него быстрые углеводы, которые не содержат полезных веществ и трансформируются в жир. ",
        "2. Питайтесь в небольшом количестве через равные промежутки времени. Это избавляет от чувства голода и не дает организму накапливать лишнее на случай ужесточения диеты.",
        "3. Углеводы можно потреблять на завтрак и до обеда. Так у организма остается достаточно времени на то, чтобы переварить их, а не отложить.",
    ]
    var num: Int = 1
    var body: some View {
        ScrollView {
            Text("Рекомендации:")
                .padding(.bottom)
            VStack(alignment: .leading) {
                ForEach(texts, id: \.self) { item in
                    Text(item)
                        .padding(.bottom)
                }
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
                        .background(Color(hex: "#cfd4d4"))
                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                }
                .frame(minWidth: 200)
                .cornerRadius(5)
                .padding()
                List {
                    ForEach(meals.list, id: \.self) { item in
                        if searchText == "" || (searchText != "" && item.name.lowercased().contains(searchText.lowercased())) {
                            HStack {
                                Text(item.name)
                                Spacer()
                                Button(action: {
                                    addToCounter(meal: item)
                                }, label: {
                                    Text("Добавить")
                                        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                })
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .padding()
                VStack {
                    Text("Не нашли то, что хотели?")
                    NavigationLink(destination: AddMealView(calories: calories)) { Text("Добавьте своё!")
                            .padding()
                    }
                }
                Spacer()
            }
            //.background(.gray)
            .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
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
    @ObservedObject var calories = Calories()
    @State private var name: String = ""
    @State private var count: String = ""
    @State private var proteins: String = ""
    @State private var fats: String = ""
    @State private var carbohydrates: String = ""
    @State private var isAlertPresented: Bool = false
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
                    guard let cnt = Int(count), let prot = Int(proteins), let fts = Int(fats), let carb = Int(carbohydrates) else {
                        isAlertPresented = true
                        
                        return
                    }
                    calories.consumed.count += cnt
                    calories.consumed.proteins += prot
                    calories.consumed.fats += fts
                    calories.consumed.carbohydrates += carb
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .alert("Не все значения заполнены", isPresented: $isAlertPresented) {
                Button("OK") {
                    
                }
                
            } message: {
                Text("Пожалуйста, чтобы добавить своё блюдо, заполните все поля")
            }
        }
    }
}

#Preview {
    CounterView()
}
