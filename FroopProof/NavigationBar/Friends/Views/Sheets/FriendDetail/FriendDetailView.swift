//
//  FriendDetailView.swift
//  FroopProof
//
//  Created by David Reed on 2/16/23.
//

import SwiftUI
import UserNotifications

struct FriendDetailView: View {
    @ObservedObject var dataController = DataController.shared

    @Binding var selectedFriend: UserData
    @State var showInviteView = false
    @State var profileView: Bool = true
    @State var friendDetailOpen: Bool = false
    @State var currentFriends: [UserData] = []
    @Binding var globalChat: Bool
    var body: some View {
        ZStack {
            
            GeometryReader {
                let size = $0.size
                let safeArea = $0.safeAreaInsets
                
                UserPublicView(size: size, safeArea: safeArea, selectedFriend: $selectedFriend, profileView: $profileView, friendDetailOpen: $friendDetailOpen, friends: $currentFriends, globalChat: $globalChat)
                    .ignoresSafeArea(.all, edges: .top)
            }
            
            if dataController.allSelected > 0 {
                VStack {
                    Spacer()
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .opacity(0.7)
                            .frame(height: 100)
                        Text("Invite to a Froop")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .fontWeight(.thin)
                            .padding(.horizontal)
                            .padding(.bottom, 40)
                    }
                    .transition(.opacity)
                    
                }
                .ignoresSafeArea()
            } else {
                EmptyView()
            }
        }
    }
}

