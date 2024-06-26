//
//  ContentView.swift
//  project
//
//  Created by Анастасия Сергеева on 31.12.2023.
//

import SwiftUI

struct ContentView: View {
    @State var selectedTab = 0
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    var body: some View {
        TabView {
            CounterView()
                .tabItem {
                    Label("Главная", systemImage: "house.fill")
                }
            ExercisesView()
                .tabItem {
                    Label("Упражнения", systemImage: "dumbbell.fill")
                }
            PersonalView()
                .tabItem {
                    Label("Профиль", systemImage: "person.crop.circle")
                }
        }
        .sheet(isPresented: $isFirstLaunch, content: {
            StartView()
        })
    }
}

struct StartView: View {
    @AppStorage("isFirstLaunch") private var isFirstLaunch: Bool = true
    
    @AppStorage("username") private var username: String = ""
    @AppStorage("userage") private var userage: String = ""
    @AppStorage("userweight") private var userweight: Int = 1
    @AppStorage("userheight") private var userheight: Int = 1
    @AppStorage("recommend") private var recommend: Bool = true
    
    @AppStorage("heightUnits") private var heightUnits: String = "cm"
    @AppStorage("weightUnits") private var weightUnits: String = "kg"
    
    @State private var isAlertPresented: Bool = false
    @State private var forcedDisplay: Bool = false
    @State private var userInput: String = ""
    @State private var selectedOption: String = "Да"
    @State private var inputs: [String] = ["", "", "", ""]
    let options = ["Да", "Нет"]
    @State private var fields: [Bool] = [true, false, false, false, false]
    @State private var nextStep: Int = 1
    
    @State private var selectedWeight: String = "kg"
    @State private var weights = ["kg", "lb"]
    
    @State private var selectedHeight: String = "cm"
    @State private var heights = ["cm", "ft", "in"]
    
    var body: some View {
        NavigationView {
            HStack{
                Spacer()
                VStack {
                    Spacer()
                    Text("Добро пожаловать!")
                        .font(Font.custom("Comfortaa", size: 25))
                        .bold()
                        .padding()
                    customText("Перед началом работы мы бы хотели узнать немного о Вас:")
                        .multilineTextAlignment(.center)
                    TextField("Введите имя", text: $inputs[0])
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(Font.custom("Comfortaa", size: 17))
                    if fields[1] {
                        TextField("Введите возраст", text: $inputs[1])
                            .keyboardType(.numberPad)
                            .padding()
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(Font.custom("Comfortaa", size: 17))
                    }
                    if fields[2] {
                        HStack {
                            TextField("Введите вес", text: $inputs[2])
                                .keyboardType(.numberPad)
                                .padding()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(Font.custom("Comfortaa", size: 17))
                            Picker("Select", selection: $selectedWeight, content: {
                                ForEach(weights, id: \.self) { option in
                                    Text(option)
                                }
                            })
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }
                    if fields[3] {
                        HStack {
                            TextField("Введите рост", text: $inputs[3])
                                .keyboardType(.numberPad)
                                .padding()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Picker("Select", selection: $selectedHeight, content: {
                                ForEach(heights, id: \.self) { option in
                                    Text(option)
                                }
                            })
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }
                    if fields[4] {
                        customText("Вы хотите видеть наши рекомендации?")
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(options, id: \.self) { option in
                                RadioButton(
                                    text: option,
                                    isSelected: option == selectedOption,
                                    callback: { selectedOption = option }
                                )
                            }
                            .font(Font.custom("Comfortaa", size: 17))
                        }
                    }
                    if nextStep < 5{
                        Button(action: {
                            let currentStep = nextStep - 1
                            userInput = inputs[currentStep]
                            if userInput != "" || forcedDisplay {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    fields[nextStep].toggle()
                                    nextStep += 1
                                }
                            } else {
                                isAlertPresented = true
                            }
                        }, label: {
                            customText("Далее")
                                .foregroundColor(Color(hex: "#0209d6"))
                                .bold()
                        })
                        .padding()
                    } else {
                        
                        Button(action: {
                            isFirstLaunch = false
                            username = inputs[0]
                            userage = inputs[1]
                            if inputs[2] != "" {
                                userweight = Int(inputs[2])!
                            } else {
                                userweight = 1
                            }
                            if inputs[3] != "" {
                                userheight = Int(inputs[3])!
                            } else {
                                userheight = 1
                            }
                            recommend =  selectedOption == "Да" ? true : false
                            
                            heightUnits = selectedHeight
                            weightUnits = selectedWeight
                        }, label: {
                            customText("Готово")
                                .foregroundColor(Color(hex: "#0209d6"))
                                .bold()
                        })
                        .padding()
                    }
                    Spacer()
                }
                Spacer()
            }
            .background(Color(hex: "#7dc7b1"))
        }
        .padding()
        .background(Color(hex: "#7dc7b1"))
        .cornerRadius(20)
        .alert(isPresented: $isAlertPresented) {
            Alert(
                title: Text("Пустое поле"),
                message: Text("Вы оставили это поле пустым. Мы рекомендуем заполнить все поля сейчас, но Вы можете в любой момент вернуться к редактированию. Нажмите ОК, чтобы оставить поле пустым"),
                primaryButton: .default(Text("OK"), action: {
                    forcedDisplay = true
                }),
                secondaryButton: .cancel()
            )
        }
        
    }
}

#Preview {
    StartView()
}
