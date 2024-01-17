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
    @State private var infoIsPresented: Bool = false
    
    private var fieldsCount: Int = 5
    private var fields: [String] = ["Имя: ", "Возраст: ", "Рост", "Вес: ", "ИМТ: ", "Рекомендации: "]
    
    private var gridItems = [GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .leading)]
    var body: some View {
        let vals: [String] = [username, userage, String(userheight) + " " + String(heightUnits), String(userweight) + " " + String(weightUnits), String(bmi)]


        GeometryReader { geometry in
        VStack {
            Spacer()
            HStack {
                Button(action: {
                    infoIsPresented.toggle()
                }, label: {
                    Image(systemName: "info")
                        .padding()
                        .foregroundColor(.black)
                })
                .background(Color(hex: "#f5fffe"))
                .font(.system(size: 20))
                .cornerRadius(10)
                Spacer()
                Button(action: {
                    editing.isSheetPresented.toggle()
                }, label: {
                    customText("Изменить")
                        .padding(10)
                        .font(.system(size: 20))
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
                                customText(fields[$0])
                                    .padding()
                                
                            } else {
                                customText("Рекомендации")
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
                                        customText(String(format: "%.2f", BMI))
                                            .padding()
                                            .foregroundColor(Color(hex: "#34b0f7"))
                                    } else if BMI >= 16.0 && BMI < 18.0 {
                                        customText(String(format: "%.2f", BMI))
                                            .padding()
                                            .foregroundColor(Color(hex: "#5bc292"))
                                    } else if BMI >= 18.5 && BMI < 25.0 {
                                        customText(String(format: "%.2f", BMI))
                                            .padding()
                                            .foregroundColor(Color(hex: "#398732"))
                                    } else if BMI >= 25.0 && BMI < 30.0 {
                                        customText(String(format: "%.2f", BMI))
                                            .padding()
                                            .foregroundColor(Color(hex: "#665d2c"))
                                    } else if BMI >= 30.0 && BMI < 35.0 {
                                        customText(String(format: "%.2f", BMI))
                                            .padding()
                                            .foregroundColor(Color(hex: "#ab5307"))
                                    } else if BMI >= 35.0 && BMI < 40.0 {
                                        customText(String(format: "%.2f", BMI))
                                            .padding()
                                            .foregroundColor(Color(hex: "#800101"))
                                    } else if BMI >= 40.0 {
                                        customText(String(format: "%.2f", BMI))
                                            .padding()
                                            .foregroundColor(Color.red)
                                    }
                                } else {
                                    customText(vals[$0])
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
        .sheet(isPresented: $infoIsPresented, content: {
            InfoView(isPresented: $infoIsPresented)
        })
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

struct InfoView: View {
    @Binding var isPresented: Bool
    let gridItems = [GridItem(.flexible(), alignment: .center), GridItem(.flexible(), alignment: .center), GridItem(.flexible(), alignment: .center), GridItem(.flexible(), alignment: .center), GridItem(.flexible(), alignment: .center), GridItem(.flexible(), alignment: .center),
        GridItem(.flexible(), alignment: .center)]
    var body: some View {
        VStack {
            Spacer()
            VStack {
                Text("ИМТ — индекс массы тела. Эта величина позволяет оценить степень соответствия массы человека и его роста и тем самым косвенно судить о том, является ли масса недостаточной, нормальной или избыточной. ИМТ рассчитывается как отношение массы (в кг) к квадрату роста (в метрах).")
                    .padding()
                    .background(Color(hex: "#f5fffe"))
                    .cornerRadius(10)
                Text("В соответствии с рекомендациями ВОЗ разработана следующая интерпретация показателей ИМТ:")
                    .padding()
                    .background(Color(hex: "#f5fffe"))
                    .cornerRadius(10)
                
                VStack {
                    LazyHGrid(rows: gridItems, spacing: 5) {
                        Text("менее 16")
                            .padding(.leading)
                            .padding(.trailing)
                            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 60)
                            .background(Color(hex: "#34b0f7"))
                        Text("16—18,5")
                            .padding(.leading)
                            .padding(.trailing)
                            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 60)
                            .background(Color(hex: "#5bc292"))
                        Text("18,5—25")
                            .padding(.leading)
                            .padding(.trailing)
                            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 60)
                            .background(Color(hex: "#398732"))
                        Text("25—30")
                            .padding(.leading)
                            .padding(.trailing)
                            .foregroundColor(.white)
                            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 60)
                            .background(Color(hex: "#665d2c"))
                        Text("30—35")
                            .padding(.leading)
                            .padding(.trailing)
                            .foregroundColor(.white)
                            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 60)
                            .background(Color(hex: "#ab5307"))
                        Text("35-40")
                            .padding(.leading)
                            .padding(.trailing)
                            .foregroundColor(.white)
                            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 60)
                            .background(Color(hex: "#800101"))
                        Text("более 40")
                            .padding(.leading)
                            .padding(.trailing)
                            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 60)
                            .background(.red)
                        
                        Text("выраженный дефицит")
                            .padding(.leading)
                            .padding(.trailing)
                            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 60)
                            .background(Color(hex: "#34b0f7"))
                        Text("дефицит")
                            .padding(.leading)
                            .padding(.trailing)
                            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 60)
                            .background(Color(hex: "#5bc292"))
                        Text("норма")
                            .padding(.leading)
                            .padding(.trailing)
                            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 60)
                            .background(Color(hex: "#398732"))
                        Text("предожирение")
                            .padding(.leading)
                            .padding(.trailing)
                            .foregroundColor(.white)
                            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 60)
                            .background(Color(hex: "#665d2c"))
                        Text("ожирение 1 степени")
                            .padding(.leading)
                            .padding(.trailing)
                            .foregroundColor(.white)
                            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 60)
                            .background(Color(hex: "#ab5307"))
                        Text("ожирение 2 степени")
                            .padding(.leading)
                            .padding(.trailing)
                            .foregroundColor(.white)
                            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 60)
                            .background(Color(hex: "#800101"))
                        Text("ожирение 3 степени")
                            .padding(.leading)
                            .padding(.trailing)
                            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 60)
                            .background(.red)
                    }
                }
                
                .padding(5)
                .background(Color(hex: "#f5fffe"))
               
                Button("OK") {
                    isPresented.toggle()
                }
                .padding()
            }
            .padding()
            Spacer()
        }
        .background(Color(hex: "#9fe0d6"))
        //.padding()
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
    
    @State private var weights = ["kg", "lb"]
    @State private var heights = ["cm", "ft", "in"]
    
    @State private var heightText: String = ""
    @State private var weightText: String = ""
    
    @State private var selectedWeight: String = "kg"
    @State private var selectedHeight: String = "cm"
    
    @EnvironmentObject private var editing: EditState
    
    init() {
        _heightText = State(initialValue: "\(userheight)")
        _weightText = State(initialValue: "\(userweight)")
        _selectedHeight = State(initialValue: "\(heightUnits)")
        _selectedWeight = State(initialValue: "\(weightUnits)")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Редактировать имя")) {
                    TextField("Введите имя", text: $username)
                }
                Section(header: Text("Редактировать возраст")) {
                    TextField("Введите возраст", text: $userage)
                        .keyboardType(.numberPad)
                }
                Section(header: Text("Редактировать рост")) {
                    TextField("Введите рост", text: $heightText)
                        .keyboardType(.numberPad)
                    Picker("Select", selection: $selectedHeight, content: {
                        ForEach(heights, id: \.self) { option in
                            Text(option)
                        }
                    })
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text("Редактировать вес")) {
                    TextField("Введите вес", text: $weightText)
                        .keyboardType(.numberPad)
                    Picker("Select", selection: $selectedWeight, content: {
                        ForEach(weights, id: \.self) { option in
                            Text(option)
                        }
                    })
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("Редактирование")
            .navigationBarItems(
                trailing: Button("Готово") {
                    userheight = Int(heightText) ?? userheight
                    heightUnits = selectedHeight
                    
                    userweight = Int(weightText) ?? userweight
                    weightUnits = selectedWeight
                    editing.isSheetPresented.toggle()
                }
            )
        }
    }
}

#Preview {
    PersonalView()
}
