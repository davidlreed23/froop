//
//  FroopTabBar.swift
//  FroopProof
//
//  Created by David Reed on 2/6/23.
//

import SwiftUI
import UIKit

struct SomeParticles: View {
    var body: some View {
        Image(systemName: "circle.fill")
            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
            .modifier(ParticleEffect(pcount: 8 ))
    }
}

struct NoParticles: View {
    var body: some View {
        Text("")
    }
}

struct TabIcon: View {
    var selectedImageName: String
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var notificationsManager = NotificationsManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var locationServices = LocationServices.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    @Environment(\.colorScheme) var colorScheme
    
    var imageName: String
    var froopImageName: String = "circle"
    var tab: Tab
    var body: some View {
        
        ZStack {
            // Check if the current tab is the selected tab
            if locationServices.selectedTab == tab {
                if tab == .froop {
                    Image(froopImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                    
                } else {
                    Image(systemName: imageName)
                        .font(.system(size: 28))
                        .fontWeight(.regular)
                        .foregroundColor(locationServices.selectedTab == tab ? Color(red: 249/255, green: 0/255, blue: 98/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
                        .frame(width: 30, height: 30)
                }
            } else {
                if locationServices.selectedTab == .froop {
                    Image(froopImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                } else {
                    Image(froopImageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
                
                Image(systemName: imageName)
                    .font(.system(size: 28))
                    .fontWeight(.regular)
                    .foregroundColor(locationServices.selectedTab == tab ? Color(red: 249/255, green: 0/255, blue: 98/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
                    .frame(width: 30, height: 30)
            }
                
            if notificationsManager.badgeCounts[tab] ?? 0 > 0 {
                Text("\(notificationsManager.badgeCounts[tab] ?? 0)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 14, height: 14)
                    .background(Color(red: 249/255, green: 0/255, blue: 98/255))
                    .clipShape(Circle())
                    .offset(x: 20, y: -15)
            }
        }
    }
}



struct TabBarBackground: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let bumpHeight: CGFloat = -20
        let bumpWidth: CGFloat = 150
        
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: rect.midX - bumpWidth / 2, y: 0))
        path.addQuadCurve(to: CGPoint(x: rect.midX + bumpWidth / 2, y: 0), control: CGPoint(x: rect.midX, y: bumpHeight))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        
        return path
    }
}

struct ParticleEffect: ViewModifier {
    let pcount: Int
    let duration: Double = 2.0
    
    @State var time: Double = 0.0
    
    func body(content: Content) -> some View {
        let animation = Animation.linear(duration: duration)
            .repeatForever(autoreverses: false)
        
        return ZStack {
            
            ForEach (0..<pcount) { index in
                content
                    .hueRotation(Angle(radians: 0.5-3 * (self.time) / duration))
                    .scaleEffect(max(CGFloat((duration - self.time) / duration), 0.01))
                    .modifier(ParticleMotion(time: self.time))
                    .opacity((duration - self.time) / duration)
                    .animation(animation.delay(Double.random(in: 0..<self.duration)), value: (duration - self.time) / duration)
                    .blendMode(.plusLighter)
            }
        }
        .onAppear {
            withAnimation() {
                self.time = duration
            }
        }
        
    }
}

struct ParticleMotion: GeometryEffect {
    var time: Double // 0...?
    let v0: Double = Double.random(in: 40...80) // initial speed
    let alpha: Double = Double.random(in: 0.0..<2*Double.pi) // throw angle
    let g = 9.81  //gravity
    
    var animatableData: Double {
        get { time }
        set { time = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        
        let dx = v0 * time * cos(alpha)
        let dy = v0 * sin(alpha) * time - 0.5 * g * time * time
        
        let affineTransform = CGAffineTransform(translationX: CGFloat(dx), y: CGFloat(-dy))
        return ProjectionTransform(affineTransform)
    }
}
