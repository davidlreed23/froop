//
//  FroopDetailsView.swift
//  Design_Layouts
//
//  Created by David Reed on 6/20/23.
//

import SwiftUI
import SwiftUIBlurView
import Kingfisher
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Foundation
import MapKit
import EventKit
import FirebaseCrashlytics
import AVKit

struct FroopDetailsView: View {
    @ObservedObject var mapManager = MapManager.shared
    @ObservedObject var dataController = DataController.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var locationServices = LocationServices.shared
    @ObservedObject var flightManager = FroopFlightDataManager.shared
//    @ObservedObject var froopDataListener = FroopDataListener.shared
    @ObservedObject var myData = MyData.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var friendViewController = FriendViewController.shared
    @ObservedObject var timeZoneManager: TimeZoneManager = TimeZoneManager()
    @ObservedObject var froopData = FroopData.shared
    @ObservedObject var friendData: UserData = UserData()
    @ObservedObject var viewModel = DetailsGuestViewModel.shared
    
    @ObservedObject var payManager = PayWallManager.shared
    @ObservedObject var model: PaywallModel = PaywallModel(dictionary: [:])
    
    @State var froopDropPin: FroopDropPin = FroopDropPin()
    
    @State var tasks: [FroopTask] = []
    @State var detailGuests: [UserData] = []
    @State private var mapState = MapViewState.locationSelected
    @State private var dataLoaded = false
    @State var messageEdit = false
    @State var taskOn = false
    @State var acceptFraction1 = 1
    @State var acceptFraction2 = 1
    @State private var templateMade: Bool = false
    @State private var friendDetailOpen: Bool = false
    @State private var miniFriendDetailOpen: Bool = false
    @State private var miniFriend: UserData = UserData()
    @Binding var detailFroopData: Froop
    @Binding var froopAdded: Bool
    @State var froopStatus: FroopHistory.FroopStatus = .none
    @Binding var globalChat: Bool
    @State private var fadeIn = false

    
    @State var instanceFroop: FroopHistory = FroopHistory(
        froop: Froop(dictionary: [:]),
        host: UserData(),
        invitedFriends: [],
        confirmedFriends: [],
        declinedFriends: [],
        pendingFriends: [],
        images: [],
        videos: [],
        froopGroupConversationAndMessages: ConversationAndMessages(conversation: Conversation(), messages: [], participants: []), froopMediaData: FroopMediaData(
            froopImages: [],
            froopDisplayImages: [],
            froopThumbnailImages: [],
            froopIntroVideo: "",
            froopIntroVideoThumbnail: "",
            froopVideos: [],
            froopVideoThumbnails: []
        )
    )
    
    
    var player: AVPlayer? {
        if let url = URL(string: froopManager.selectedFroopHistory.froop.froopIntroVideo) {
            return AVPlayer(url: url)
        } else {
            return nil
        }
    }
    
    var timestamp: Date = Date()
    
    var body: some View {
        ZStack (){
           
            VStack (spacing: 0 ){
                
                DetailsHeaderView(templateMade: $templateMade)
                    .frame(height: 225)
                    .onAppear {
                        froopStatus = froopManager.selectedFroopHistory.froopStatus
                    }
                    .onDisappear {
                        froopStatus = .none
                    }
                
                
                VStack {
                    switch froopStatus {
                            
                        case .none:
                            EmptyView()
                            
                        case .confirmed:
                            
                            if froopManager.selectedFroopHistory.host.froopUserID == Auth.auth().currentUser?.uid ?? "" {
                            
                                if froopManager.selectedFroopHistory.froop.froopType == 5009 {
                                    // Flight Pickup Froop - Host View
                                    ScrollView {
                                        VStack (spacing: 0){
                                            PremiumBannerDetailsView()
                                                .frame(height: myData.premiumAccount ? 25 : 75)
                                            ZStack {
                                                Rectangle()
                                                    .frame(height: 100)
                                                    .foregroundColor(.offWhite)
                                                VStack {
                                                    HStack {
                                                        VStack(alignment: .leading) {
                                                            Text(froopManager.selectedFroopHistory.froop.flightData?.departure.airport.iata ?? "DDD")
                                                                .font(.system(size: 20))
                                                                .fontWeight(.bold)
                                                            Text(froopManager.selectedFroopHistory.froop.flightData?.departure.airport.municipalityName ?? "New York")
                                                                .font(.system(size: 14))
                                                                .fontWeight(.light)
                                                        }
                                                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                                        .padding(.leading, 20)
                                                        
                                                        Spacer()
                                                        
                                                        VStack(alignment: .center) {
                                                            Image(systemName: "airplane.departure")
                                                                .foregroundColor(Color(red: 100/255, green: 155/255, blue: 255/255))
                                                                .font(.system(size: 24))
                                                        }
                                                        
                                                        Spacer()
                                                        
                                                        VStack(alignment: .trailing) {
                                                            Text(froopManager.selectedFroopHistory.froop.flightData?.arrival.airport.iata ?? "AAA")
                                                                .font(.system(size: 20))
                                                                .fontWeight(.bold)
                                                            Text(froopManager.selectedFroopHistory.froop.flightData?.arrival.airport.municipalityName ?? "Los Angeles")
                                                                .font(.system(size: 14))
                                                                .fontWeight(.light)
                                                        }
                                                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                                        .padding(.trailing, 20)
                                                    }
                                                    HStack {
                                                        VStack(alignment: .leading) {
                                                            Text("Departing")
                                                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                                                .font(.system(size: 12))
                                                                .fontWeight(.light)
                                                            if let utcDate = flightManager.dateFromUTCString(froopManager.selectedFroopHistory.froop.flightData?.departure.scheduledTime.utc ?? "") {
                                                                let adjustedDate = DateUtilities.adjustDateByOffsets(date: utcDate, dstOffset: timeZoneManager.departingTimeZone?.dstOffset, rawOffset: timeZoneManager.departingTimeZone?.rawOffset)
                                                                Text("\(timeZoneManager.formatTime(from: utcDate, timeZoneIdentifier: timeZoneManager.departingTimeZone?.timeZoneId ?? TimeZone.current.identifier))")
                                                                    .font(.system(size: 14))
                                                                    .fontWeight(.semibold)
                                                                    .foregroundColor(Color(red: 100/255, green: 155/255, blue: 255/255))
                                                            } else {
                                                                Text("Time not available")
                                                            }
                                                        }
                                                        Spacer()
                                                        VStack(alignment: .trailing) {
                                                            Text("Arriving")
                                                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                                                .font(.system(size: 12))
                                                                .fontWeight(.light)
                                                            if let utcDate = flightManager.dateFromUTCString(froopManager.selectedFroopHistory.froop.flightData?.arrival.scheduledTime.utc ?? "") {
                                                                let adjustedDate = DateUtilities.adjustDateByOffsets(date: utcDate, dstOffset: timeZoneManager.arrivingTimeZone?.dstOffset, rawOffset: timeZoneManager.arrivingTimeZone?.rawOffset)
                                                                Text("\(timeZoneManager.formatTime(from: utcDate, timeZoneIdentifier: timeZoneManager.arrivingTimeZone?.timeZoneId ?? TimeZone.current.identifier))")
                                                                    .font(.system(size: 14))
                                                                    .fontWeight(.semibold)
                                                                    .foregroundColor(Color(red: 100/255, green: 155/255, blue: 255/255))
                                                            } else {
                                                                Text("Time not available")
                                                            }
                                                        }
                                                    }
                                                    .padding(.leading, 20)
                                                    .padding(.trailing, 20)
                                                    .padding(.top, 5)

                                                }
                                            }
                                            
                                            ZStack {
                                                Rectangle()
                                                VStack{
                                                    FlightMapView()
                                                }
                                            }
                                            .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight * 0.25)
                                            
                                            if $froopManager.selectedFroopHistory.froop.guestApproveList.count > 0 {
                                                withAnimation {
                                                    PendingGuestView(selectedFroopHistory: $froopManager.selectedFroopHistory, miniFriendDetailOpen: $miniFriendDetailOpen, miniFriend: $miniFriend)
                                                }
                                            }
                                            
                                            DetailsGuestView(selectedFroopHistory: $froopManager.selectedFroopHistory, miniFriendDetailOpen: $miniFriendDetailOpen, miniFriend: $miniFriend)
                                            
                                            DetailsCalendarView(selectedFroopHistory: $froopManager.selectedFroopHistory)
                                            
                                            DetailsMapView(selectedFroopHistory: $froopManager.selectedFroopHistory)
                                            
                                            DetailsTasksAndInformationView(taskOn: $taskOn, selectedFroopHistory: $froopManager.selectedFroopHistory)
                                            
                                            DetailsDeleteView(froopAdded: $froopAdded, selectedFroopHistory: $froopManager.selectedFroopHistory)
                                            Spacer()
                                        }
                                    }
                                    .scrollIndicators(.hidden)
                                    .frame(maxWidth: UIScreen.screenWidth, maxHeight: UIScreen.screenHeight - 300)
                                } else {
                                    // Generic Froop - Host View
                                    ScrollView {
                                        VStack (spacing: 0){
                                            PremiumBannerDetailsView()
                                                .frame(height: myData.premiumAccount ? 25 : 75)
                                            DetailsHostMessageView(selectedFroopHistory: $froopManager.selectedFroopHistory, messageEdit: $messageEdit)
                                            if $froopManager.selectedFroopHistory.froop.guestApproveList.count > 0 {
                                                withAnimation {
                                                    PendingGuestView(selectedFroopHistory: $froopManager.selectedFroopHistory, miniFriendDetailOpen: $miniFriendDetailOpen, miniFriend: $miniFriend)
                                                }
                                            }
                                            DetailsGuestView(selectedFroopHistory: $froopManager.selectedFroopHistory, miniFriendDetailOpen: $miniFriendDetailOpen, miniFriend: $miniFriend)
                                            
                                            DetailsCalendarView(selectedFroopHistory: $froopManager.selectedFroopHistory)
                                            DetailsMapView(selectedFroopHistory: $froopManager.selectedFroopHistory)
                                            DetailsTasksAndInformationView(taskOn: $taskOn, selectedFroopHistory: $froopManager.selectedFroopHistory)
                                            DetailsDeleteView(froopAdded: $froopAdded, selectedFroopHistory: $froopManager.selectedFroopHistory)
                                            Spacer()
                                        }
                                    }
                                    .scrollIndicators(.hidden)
                                    .frame(maxWidth: UIScreen.screenWidth, maxHeight: UIScreen.screenHeight - 300)
                                }
                                
                            } else {
                                
                                if froopManager.selectedFroopHistory.froop.froopType == 5009 {
                                    // Flight Pickup Froop - Guest View
                                    ScrollView {
                                        VStack (spacing: 0){
                                            DetailsGuestMessageView(selectedFroopHistory: $froopManager.selectedFroopHistory, messageEdit: $messageEdit)
                                            DetailsGuestView(selectedFroopHistory: $froopManager.selectedFroopHistory, miniFriendDetailOpen: $miniFriendDetailOpen, miniFriend: $miniFriend)
                                            DetailsCalendarView(selectedFroopHistory: $froopManager.selectedFroopHistory)
                                            DetailsMapView(selectedFroopHistory: $froopManager.selectedFroopHistory)
                                            DetailsTasksAndInformationView(taskOn: $taskOn, selectedFroopHistory: $froopManager.selectedFroopHistory)
                                            DetailsDeleteView(froopAdded: $froopAdded, selectedFroopHistory: $froopManager.selectedFroopHistory)
                                            //                                            .frame(maxHeight: 110)
                                            
                                            
                                            Spacer()
                                        }
                                    }
                                    .scrollIndicators(.hidden)
                                    .frame(maxWidth: UIScreen.screenWidth, maxHeight: UIScreen.screenHeight - 300)
                                    
                                } else {
                                    
                                    // Generic Froop - Guest View
                                    ScrollView {
                                        VStack (spacing: 0){
                                            DetailsGuestMessageView(selectedFroopHistory: $froopManager.selectedFroopHistory, messageEdit: $messageEdit)
                                            DetailsGuestView(selectedFroopHistory: $froopManager.selectedFroopHistory, miniFriendDetailOpen: $miniFriendDetailOpen, miniFriend: $miniFriend)
                                            DetailsCalendarView(selectedFroopHistory: $froopManager.selectedFroopHistory)
                                            DetailsMapView(selectedFroopHistory: $froopManager.selectedFroopHistory)
                                            DetailsTasksAndInformationView(taskOn: $taskOn, selectedFroopHistory: $froopManager.selectedFroopHistory)
                                            DetailsDeleteView(froopAdded: $froopAdded, selectedFroopHistory: $froopManager.selectedFroopHistory)
                                            //                                            .frame(maxHeight: 110)
                                            
                                            
                                            Spacer()
                                        }
                                    }
                                    .scrollIndicators(.hidden)
                                    .frame(maxWidth: UIScreen.screenWidth, maxHeight: UIScreen.screenHeight - 300)
                                    
                                }
                            }
                            DetailsAddFriendsView(froopAdded: $froopAdded)
                                .ignoresSafeArea()
                            
                        case .archived:
                            ScrollView {
                                VStack (spacing: 0){
                                    DetailsMediaView()
                                    DetailsGuestView(selectedFroopHistory: $froopManager.selectedFroopHistory, miniFriendDetailOpen: $miniFriendDetailOpen, miniFriend: $miniFriend)
                                    DetailsCalendarView(selectedFroopHistory: $froopManager.selectedFroopHistory)
                                    DetailsMapView(selectedFroopHistory: $froopManager.selectedFroopHistory)
                                    DetailsGuestMessageView(selectedFroopHistory: $froopManager.selectedFroopHistory, messageEdit: $messageEdit)
                                    DetailsDeleteView(froopAdded: $froopAdded, selectedFroopHistory: $froopManager.selectedFroopHistory)
                                        .frame(maxHeight: 110)
                                    
                                    Spacer()
                                }
                            }
                            .scrollIndicators(.hidden)
                            .frame(maxWidth: UIScreen.screenWidth, maxHeight: UIScreen.screenHeight - 300)
                            DetailsAddFriendsView(froopAdded: $froopAdded)
                            
                        case .memory:
                            ScrollView {
                                VStack (spacing: 0) {
                                    DetailsMediaView()
                                    DetailsGuestView(selectedFroopHistory: $froopManager.selectedFroopHistory, miniFriendDetailOpen: $miniFriendDetailOpen, miniFriend: $miniFriend)
                                    DetailsCalendarView(selectedFroopHistory: $froopManager.selectedFroopHistory)
                                    DetailsMapView(selectedFroopHistory: $froopManager.selectedFroopHistory)
                                    DetailsGuestMessageView(selectedFroopHistory: $froopManager.selectedFroopHistory, messageEdit: $messageEdit)
                                    DetailsDeleteView(froopAdded: $froopAdded, selectedFroopHistory: $froopManager.selectedFroopHistory)
                                        .frame(maxHeight: 110)
                                    
                                    Spacer()
                                }
                            }
                            .scrollIndicators(.hidden)
                            .frame(maxWidth: UIScreen.screenWidth, maxHeight: UIScreen.screenHeight - 300)
                            DetailsAddFriendsView(froopAdded: $froopAdded)
                            
                        default:
                            EmptyView() // For any other unhandled cases
                    }
                }
                .background(Color(red: 50/255, green: 46/255, blue: 62/255))
                Spacer()
                    .frame(height: 1)
            }
            
            .fullScreenCover(isPresented: $froopManager.archivedImageViewOpen) {
            } content: {
                ZStack {
                    ArchivedMediaShareViewParent()
                    
                    VStack {
                        Spacer()
                        Button (action: {
                            froopManager.archivedImageViewOpen.toggle()
                        }) {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .border(Color(red: 50/255, green: 46/255, blue: 62/255), width: 0.25)
                                    .frame(width: 200, height: 50)
                                Text("Close")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                    .fontWeight(.thin)
                            }
                        }
                        .padding(.bottom, 50)
                    }
                    .ignoresSafeArea()
                }
            }
            
            //MARK: FRIEND DETAIL VIEW OPEN
            .fullScreenCover(isPresented: $miniFriendDetailOpen) {
                //                friendListViewOpen = false
            } content: {
                ZStack {
                    VStack {
                        Spacer()
                        UserDetailView2(selectedFriend: $miniFriend, globalChat: $globalChat)
                        //                        .ignoresSafeArea()
                    }
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "xmark")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .blendMode(.difference)
                                .padding(.trailing, 40)
                                .padding(.top, UIScreen.screenHeight * 0.005)
                                .onTapGesture {
                                    dataController.allSelected = 0
                                    self.miniFriendDetailOpen = false
                                    //                                    print("CLEAR TAP MainFriendView 2")
                                }
                        }
                        .frame(alignment: .trailing)
                        Spacer()
                    }
                }
            }
            
            //MARK: FRIEND DETAIL VIEW OPEN
            .fullScreenCover(isPresented: $friendDetailOpen) {
                //                friendListViewOpen = false
            } content: {
                ZStack {
                    VStack {
                        Spacer()
                        UserDetailView2(selectedFriend: $dataController.selectedUser, globalChat: $globalChat)
                        //                        .ignoresSafeArea()
                    }
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "xmark")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .blendMode(.difference)
                                .padding(.trailing, 25)
                                .padding(.top, 20)
                                .onTapGesture {
                                    dataController.allSelected = 0
                                    self.friendDetailOpen = false
                                    //                                    print("CLEAR TAP MainFriendView 2")
                                }
                        }
                        .frame(alignment: .trailing)
                        Spacer()
                    }
                }
            }
            
            .fullScreenCover(isPresented: $taskOn) {
                FroopTasksView(tasks: tasks, taskOn: $taskOn)
                    .ignoresSafeArea()
            }
            
            .fullScreenCover(isPresented: $messageEdit) {
                DetailsHostMessageEditView(messageEdit: $messageEdit)
                    .ignoresSafeArea()
            }
            
            .fullScreenCover(isPresented: $froopManager.addFriendsOpen) {
            } content: {
                ZStack {
                    VStack {
                        Spacer()
                        AddFriendsFroopView(friendDetailOpen: $friendDetailOpen, addFriendsOpen: $froopManager.addFriendsOpen, timestamp: timestamp, detailGuests: $detailGuests, selectedFroopHistory: $froopManager.selectedFroopHistory)
                    }
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "xmark")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .blendMode(.difference)
                                .padding(.trailing, 40)
                                .padding(.top, UIScreen.screenHeight * 0.005)
                                .onTapGesture {
                                    self.froopManager.addFriendsOpen = false
                                }
                        }
                        .frame(alignment: .trailing)
                        Spacer()
                    }
                }
                .presentationDetents([.large])
            }
            
            if froopManager.froopMapOpen {
                ZStack {
                    PassiveMapView(froopHistory: instanceFroop, globalChat: $globalChat)
                        .frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight)
                    
                    VStack {
                        ZStack {
//                            Rectangle()
//                                .frame(width: UIScreen.screenWidth, height: 75)
//                                .foregroundColor(.clear)
//                                .background(.ultraThinMaterial)
//                                .opacity(1)

                            HStack {
                                Spacer()
                                ZStack {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 36))
                                        .foregroundColor(.black).opacity(0.5)
                                        .background(.ultraThinMaterial)
                                        .mask {
                                            Circle()
                                        }
                                    
                                    Image(systemName: "xmark")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                }
                                
                            }
                            .padding(.trailing, 23)
                            .padding(.top, UIScreen.screenHeight * 0.058)

                        }
                        
                        .frame(alignment: .top)
//                        .padding(.top, 35)
                        .onTapGesture {
                            froopManager.froopMapOpen = false
                        }
                        Spacer()
                    }
                    
                    if (MapManager.shared.showSavePassivePinView) {
                        VStack {
                            Spacer()
                            ZStack (alignment: .top) {
                                BlurView(style: .light)
                                    .frame(height: MapManager.shared.onSelected ? UIScreen.screenHeight * 0.6 : UIScreen.screenHeight * 0.4)
                                //                        .edgesIgnoringSafeArea(.bottom)
                                    .opacity(MapManager.shared.showSavePassivePinView ? 1 : 0)
                                    .ignoresSafeArea()
                                    .border(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.5), width: 0.5)
                                    .animation(.easeInOut(duration: 0.3), value: MapManager.shared.showSavePassivePinView)
                                    .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.3), radius: 20)
                                
                                
                                PassivePinDetails(froopDropPin: froopDropPin)
                                    .transition(.move(edge: .bottom))
                                    .opacity(MapManager.shared.showSavePassivePinView ? 1 : 0)
                                    .frame(height: UIScreen.screenHeight * 0.4)
                                
                            }
                            .ignoresSafeArea()
                        }
                        .ignoresSafeArea()
                    }
                    if (MapManager.shared.showPassivePinDetailsView) {
                        VStack {
                            Spacer()
                            ZStack (alignment: .top) {
                                BlurView(style: .light)
                                    .frame(height: MapManager.shared.onSelected ? UIScreen.screenHeight * 0.6 : UIScreen.screenHeight * 0.4)
                                //                        .edgesIgnoringSafeArea(.bottom)
                                    .opacity(MapManager.shared.showPassivePinDetailsView ? 1 : 0)
                                    .ignoresSafeArea()
                                    .border(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.5), width: 0.5)
                                    .animation(.easeInOut(duration: 0.3), value: MapManager.shared.showPassivePinDetailsView)
                                    .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.3), radius: 20)
                                
                                
                                CreatedPassivePinDetailsView(froopDropPin: mapManager.createdPinDetail)
                                    .transition(.move(edge: .bottom))
                                    .opacity(MapManager.shared.showPassivePinDetailsView ? 1 : 0)
                                    .frame(height: UIScreen.screenHeight * 0.4)
                                
                            }
                            .ignoresSafeArea()
                        }
                        .ignoresSafeArea()
                    }
                }
            }
            
            CustomPayWallView(
                model: $payManager.model
            )
            .offset(y: payManager.showIAPView ? 0 : UIScreen.main.bounds.height)
            .opacity(payManager.showIAPView ? 1 : 0)
            .edgesIgnoringSafeArea(.all)
            .onChange(of: payManager.showIAPView) { oldValue, newValue in
                if newValue {
                    Task {
                        do {
                            try await payManager.fetchPaywallData()
                        } catch {
                            print(error.localizedDescription)
                            payManager.showDefaultView = true
                        }
                    }
                }
            }
            if froopManager.showVideoPlayer {
                CustomVideoPlayerView(videoURLString: froopManager.selectedFroopHistory.froop.froopIntroVideo == "" ? froopManager.videoUrl : froopManager.selectedFroopHistory.froop.froopIntroVideo) {
                    froopManager.showVideoPlayer = false
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5)) {
                fadeIn = true
            }
        }
        .ignoresSafeArea()
    }
}





