//
//  WindowsView.swift
//  project
//
//  Created by Анастасия Сергеева on 01.01.2024.
//

import SwiftUI

class EditState: ObservableObject {
    @Published var isSheetPresented = false
}

struct PersonalView: View {
    @State private var isToggled = true
    @AppStorage("username") private var username: String = ""
    @AppStorage("userage") private var userage: String = ""
    @AppStorage("userweight") private var userweight: Int = 1
    @AppStorage("userheight") private var userheight: Int = 1
    @AppStorage("recommend") private var recommend: Bool = true
    @AppStorage("BMI") private var bmi: Double = 0.0
    
    @AppStorage("heightUnits") private var heightUnits: String = "cm"
    @AppStorage("weightUnits") private var weightUnits: String = "kg"
    
    @StateObject var editing = EditState()
    
    private var fieldsCount: Int = 5
    private var fields: [String] = ["Имя: ", "Возраст: ", "Рост", "Вес: ", "ИМТ: ", "Рекомендации: "]
    
    private var gridItems = [GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading)]
    var body: some View {
        let vals: [String] = [username, userage, String(userheight) + " " + String(heightUnits), String(userweight) + " " + String(weightUnits), String(bmi)]


        GeometryReader { geometry in
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    editing.isSheetPresented.toggle()
                }, label: {
                    Text("Изменить")
                        .padding(10)
                        .foregroundColor(.black)
                })
                .background(Color(hex: "#f5fffe"))
                .cornerRadius(10)
                //.padding(5)
            }
            .padding()
                HStack {
                    Spacer()
                    LazyHGrid(rows: gridItems, spacing: 0) {
                        ForEach(0..<fieldsCount + 1) {
                            if $0 < fieldsCount {
                                Text(fields[$0])
                                    .padding()
                                
                            } else {
                                Text("Рекомендации")
                                    .padding()
                            }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 55, maxHeight: 60)
                        .background(Color(hex: "#f5fffe"))

                        
                        
                        ForEach(0..<fieldsCount + 1) {
                            if $0 < fieldsCount {
                                if $0 == fieldsCount - 1 {
                                    let BMI = getBMI()
                                    if BMI < 16.0 {
                                        Text(vals[$0])
                                            .padding()
                                            .foregroundColor(Color(hex: "#c0e6fc"))
                                    } else if BMI >= 16.0 && BMI < 18.0 {
                                        Text(vals[$0])
                                            .padding()
                                            .foregroundColor(Color(hex: "#c0fce0"))
                                    } else if BMI >= 18.5 && BMI < 25.0 {
                                        Text(vals[$0])
                                            .padding()
                                            .foregroundColor(Color(hex: "#b6f7b0"))
                                    } else if BMI >= 25.0 && BMI < 30.0 {
                                        Text(vals[$0])
                                            .padding()
                                            .foregroundColor(Color(hex: "#7bcf74"))
                                    } else if BMI >= 30.0 && BMI < 35.0 {
                                        Text(vals[$0])
                                            .padding()
                                            .foregroundColor(Color(hex: "#fc9e4c"))
                                    } else if BMI >= 35.0 && BMI < 40.0 {
                                        Text(vals[$0])
                                            .padding()
                                            .foregroundColor(Color(hex: "#fc784c"))
                                    } else if BMI >= 40.0 {
                                        Text(vals[$0])
                                            .padding()
                                            .foregroundColor(Color.red)
                                    }
                                } else {
                                    Text(vals[$0])
                                        .padding()
                                }
                            } else {
                                Toggle("Показывать рекомендации", isOn: $recommend)
                                    .padding()
                                    .labelsHidden()
                            }
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 55, maxHeight: 60)
                        .background(Color(hex: "#f5fffe"))
                        
                        Spacer()
                    }
                    Spacer()
                }
                Spacer()
            }
        .background(Color(hex: "#9fe0d6"))
        }
        .sheet(isPresented: $editing.isSheetPresented, content: {
            EditView()
        })
        .environmentObject(editing)
    }
    
    func getBMI() -> Double {
        var height: Int = 1
        var weight: Int = 1
        switch heightUnits {
        case "cm":
            height = userheight
        case "ft":
            height = Int(Double(userheight) * 12 * 2.54)
        case "in":
            height = Int(Double(userheight) * 2.54)
        default:
            break
        }
        
        switch weightUnits {
        case "kg":
            weight = userweight
        case "lb":
            weight = Int(Double(userweight) / 2.2)
        default:
            break
        }
        let BMI = Double(Double(weight) / ((Double(height) / 100.0) * (Double(height) / 100.0)))
        bmi = round(BMI / 0.01) * 0.01
        return round(BMI / 0.01) * 0.01
    }
}

struct EditView: View {
    @AppStorage("username") private var username: String = ""
    @AppStorage("userage") private var userage: String = ""
    @AppStorage("userweight") private var userweight: Int = 1
    @AppStorage("userheight") private var userheight: Int = 1
    @AppStorage("recommend") private var recommend: Bool = true
    
    @AppStorage("heightUnits") private var heightUnits: String = "cm"
    @AppStorage("weightUnits") private var weightUnits: String = "kg"
    
    @State private var heightText: String = ""
    @State private var weightText: String = ""
    
    @EnvironmentObject private var editing: EditState
    
    init() {
        _heightText = State(initialValue: "\(userheight)")
        _weightText = State(initialValue: "\(userweight)")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Редактировать имя")) {
                    TextField("Введите текст", text: $username)
                }
                Section(header: Text("Редактировать возраст")) {
                    TextField("Введите текст", text: $userage)
                }
                Section(header: Text("Редактировать рост")) {
                    TextField("Введите текст", text: $heightText)
                        .keyboardType(.numberPad)
                }
                Section(header: Text("Редактировать вес")) {
                    TextField("Введите текст", text: $weightText)
                }
            }
            .navigationTitle("Редактирование")
            .navigationBarItems(
                trailing: Button("Готово") {
                    userheight = Int(heightText) ?? userheight
                    userweight = Int(weightText) ?? userweight
                    editing.isSheetPresented.toggle()
                }
            )
        }
    }
}

#Preview {
    PersonalView()
}
