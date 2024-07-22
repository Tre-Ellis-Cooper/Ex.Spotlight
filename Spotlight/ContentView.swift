//
//  ContentView.swift
//  SpotlightTest
//
//  Created by Tre Cooper on 2/26/21.
//

import SwiftUI

/// Example app content view to demonstrate the spotlight system.
///
/// - note: Take note of how elements call `.spotlightElement()` and how
///         `startSpotlight` sends a spotlight to the `AppModel`.
struct ContentView: View {
    @EnvironmentObject var appModel: AppModel
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Colors.primaryBackground
                .edgesIgnoringSafeArea(.all)
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 30) {
                    Heading()
                    ThisSection()
                    ThatSection()
                }
            }
            StartButton()
        }
        .foregroundColor(Colors.primaryText)
        .onAppear(perform: startSpotlight)
    }
}

// MARK: - Helper Functions
extension ContentView {
    private func startSpotlight() {
        appModel.spotlight
            .send(Constants.Onboarding.homeSequence)
    }
}

// MARK: - View Components
extension ContentView {
    @ViewBuilder private func Border<S: InsettableShape>(
        _ InsettableShape: S
    ) -> some View {
        Colors.secondaryText
            .clipShape(
                InsettableShape
                    .inset(by: 0.5)
                    .stroke()
            )
    }
    
    @ViewBuilder private func StartButton() -> some View {
        Button(action: startSpotlight) {
            Icons.play
                .resizable()
                .frame(width: 25, height: 25)
                .spotlightElement(key: Keys.start)
                .padding(.horizontal, 25)
                .padding(.vertical, 12)
                .background(Colors.highlight)
                .foregroundColor(Colors.primaryBackground)
        }
    }
    
    @ViewBuilder private func Heading() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading) {
                Text(Strings.ex)
                    .font(.footnote.bold())
                    .opacity(0.5)
                Text(Strings.spotlight)
                    .font(.title.bold())
            }
            .spotlightElement(key: Keys.heading)
            Text(Strings.deploymentTarget)
                .font(.caption.bold())
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .overlay(Border(Capsule()))
                .spotlightElement(
                    key: Keys.targetOS,
                    shape: .rectangle(cornerRadius: 12)
                )
        }
        .padding(.top, 25)
        .padding(.horizontal, 25)
    }
    
    @ViewBuilder private func ThisSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Strings.thisSection)
                .font(.caption.bold())
                .padding(.horizontal, 25)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(1 ..< 4) { value in
                        ThisSectionCard(value: value)
                    }
                }
                .spotlightElement(
                    key: Keys.thisSection,
                    shape: .rectangle(cornerRadius: 12)
                )
                .padding(.horizontal, 25)
            }
        }
    }
    
    @ViewBuilder private func ThatSection() -> some View {
        VStack(spacing: 12) {
            HStack {
                Text(Strings.thatSection)
                    .font(.caption.bold())
                Spacer(minLength: 50)
            }
            LazyVStack(spacing: 16) {
                ForEach(1 ..< 4) { value in
                    ThatSectionCard(value: value)
                }
            }
            .spotlightElement(
                key: Keys.thatSection,
                shape: .rectangle(cornerRadius: 12)
            )
        }
        .font(.caption)
        .padding(.horizontal, 25)
    }
    
    @ViewBuilder private func ThisSectionCard(value: Int) -> some View {
        VStack(alignment: .leading, spacing: .zero) {
            ZStack {
                Colors.secondaryBackground
                Icons.photo
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(Strings.infoCategory)
                    .font(.caption.smallCaps())
                    .foregroundColor(Colors.secondaryText)
                Text(String(format: Strings.thisCardHeadingFormat, value))
                    .bold()
                Spacer()
                Text(Strings.seeMore)
                    .bold()
            }
            .spotlightElement(
                key: String(format: Keys.thisCardInfoFormat, value),
                shape: .rectangle(cornerRadius: 12)
            )
            .padding(12)
            .font(.caption)
        }
        .frame(width: 150, height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(Border(RoundedRectangle(cornerRadius: 12)))
        .spotlightElement(
            key: String(format: Keys.thisCardFormat, value),
            shape: .rectangle(cornerRadius: 12)
        )
    }
    
    @ViewBuilder private func ThatSectionCard(value: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Colors.secondaryBackground
                    Icons.photo
                }
                .clipShape(Circle())
                .frame(width: 40, height: 40)
                .spotlightElement(
                    key: String(format: Keys.thatCardImageFormat, value)
                )
                Text(String(format: Strings.thatCardHeadingFormat, value))
                    .bold()
                Spacer()
            }
            Text(Strings.thatCardInfo)
        }
        .padding(12)
        .overlay(Border(RoundedRectangle(cornerRadius: 12)))
        .spotlightElement(
            key: String(format: Keys.thatCardFormat, value),
            shape: .rectangle(cornerRadius: 12)
        )
    }
}

// MARK: - Previews
struct ContentView_Previews: PreviewProvider {
    @ObservedObject static var appModel = AppModel()
    
    static var previews: some View {
        ContentView()
            .presentSpotlight(appModel.spotlight)
            .environmentObject(appModel)
    }
}
