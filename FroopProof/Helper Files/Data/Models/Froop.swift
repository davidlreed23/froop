//
//  Froop.swift
//  FroopProof
//
//  Created by David Reed on 1/19/23.
//

import SwiftUI
import MapKit
import FirebaseFirestore

struct Froop: Identifiable, Hashable {
    
    let id = UUID()
    var froopId: String
    var froopName: String
    var froopType: Int
    var froopLocationid: Int
    var froopLocationtitle: String
    var froopLocationsubtitle: String
    var froopLocationCoordinate: CLLocationCoordinate2D?
    var froopDate: Date
    var froopStartTime: Date
    var froopCreationTime: Date
    var froopDuration: Int
    var froopInvitedFriends: [String]
    var froopImages: [String]
    var froopDisplayImages: [String]
    var froopThumbnailImages: [String]
    var froopVideos: [String]
    var froopVideoThumbnails: [String]
    var froopIntroVideo: String
    var froopIntroVideoThumbnail: String
    var froopHost: String
    var froopHostPic: String
    var froopTimeZone: String
    var froopEndTime: Date
    var froopMessage: String
    var froopList: [String]
    var template: Bool
    var hidden: [String]
    var inviteUrl: String
    var videoSubscribed: Bool
    var guestApproveList: [String]
    
    init(dictionary: [String: Any]) {
        // Extracting the froopTimeZone from the dictionary
        let froopTimeZone = String(describing: TimeZoneManager.shared.userLocationTimeZone)
        
        // Create a DateFormatter instance to handle the conversion
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone(identifier: froopTimeZone) ?? TimeZone.current
        
        guard let froopHost = dictionary["froopHost"] as? String,
              let froopId = dictionary["froopId"] as? String
        else {
            self.froopId = ""
            self.froopHost = ""
            self.froopName = ""
            self.froopType = 0
            self.froopLocationid = 0
            self.froopLocationtitle = ""
            self.froopLocationsubtitle = ""
            if let geoPoint = dictionary["froopLocationCoordinate"] as? GeoPoint {
                self.froopLocationCoordinate = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
            } else {
                self.froopLocationCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
            }
            self.froopDate = Date()
            self.froopStartTime = Date()
            self.froopCreationTime = Date()
            self.froopDuration = 0
            self.froopInvitedFriends = []
            self.froopImages = []
            self.froopDisplayImages = []
            self.froopThumbnailImages = []
            self.froopVideos = []
            self.froopVideoThumbnails = []
            self.froopIntroVideo = ""
            self.froopIntroVideoThumbnail = ""
            self.froopHostPic = ""
            self.froopTimeZone = ""
            self.froopEndTime = Date()
            self.froopMessage = ""
            self.froopList = []
            self.template = false
            self.hidden = []
            self.inviteUrl = ""
            self.videoSubscribed = false
            self.guestApproveList = []
            return
        }
        
        if let froopDateTimestamp = dictionary["froopDate"] as? Timestamp {
            self.froopDate = dateFormatter.date(from: dateFormatter.string(from: froopDateTimestamp.dateValue())) ?? Date()
        } else {
            self.froopDate = Date()
        }
        
        if let froopStartTimeTimestamp = dictionary["froopStartTime"] as? Timestamp {
            self.froopStartTime = dateFormatter.date(from: dateFormatter.string(from: froopStartTimeTimestamp.dateValue())) ?? Date()
        } else {
            self.froopStartTime = Date()
        }
        
        if let froopEndTimeTimestamp = dictionary["froopEndTime"] as? Timestamp {
            self.froopEndTime = dateFormatter.date(from: dateFormatter.string(from: froopEndTimeTimestamp.dateValue())) ?? Date()
        } else {
            self.froopEndTime = Date()
        }
        
        self.froopId = froopId
        self.froopHost = froopHost
        self.froopName = dictionary["froopName"] as? String ?? ""
        self.froopType = dictionary["froopType"] as? Int ?? 0
        self.froopLocationid = dictionary["froopLocationid"] as? Int ?? 0
        self.froopLocationtitle = dictionary["froopLocationtitle"] as? String ?? ""
        self.froopLocationsubtitle = dictionary["froopLocationsubtitle"] as? String ?? ""
        
        if let geoPoint = dictionary["froopLocationCoordinate"] as? GeoPoint {
            self.froopLocationCoordinate = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
        } else {
            self.froopLocationCoordinate = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        }
        
        self.froopCreationTime = (dictionary["froopCreationTime"] as? Timestamp)?.dateValue() ?? Date()
        self.froopDuration = dictionary["froopDuration"] as? Int ?? 0
        self.froopInvitedFriends = dictionary["froopInvitedFriends"] as? [String] ?? []
        self.froopImages = dictionary["froopImages"] as? [String] ?? []
        self.froopDisplayImages = dictionary["froopDisplayImages"] as? [String] ?? []
        self.froopThumbnailImages = dictionary["froopThumbnailImages"] as? [String] ?? []
        self.froopVideos = dictionary["froopVideos"] as? [String] ?? []
        self.froopVideoThumbnails = dictionary["froopVideoThumbnails"] as? [String] ?? []
        self.froopIntroVideo = dictionary["froopIntroVideo"] as? String ?? ""
        self.froopIntroVideoThumbnail = dictionary["froopIntroVideoThumbnail"] as? String ?? ""
        self.froopHostPic = dictionary["froopHostPic"] as? String ?? ""
        self.froopTimeZone = dictionary["froopTimeZone"] as? String ?? ""
        self.froopMessage = dictionary["froopMessage"] as? String ?? ""
        self.froopList = dictionary["froopList"] as? [String] ?? []
        self.template = dictionary["template"] as? Bool ?? false
        self.hidden = dictionary["hidden"] as? [String] ?? []
        self.inviteUrl = dictionary["inviteUrl"] as? String ?? ""
        self.videoSubscribed = dictionary["videoSubscribed"] as? Bool ?? false
        self.guestApproveList = dictionary["guestApproveList"] as? [String] ?? []
        
    }
    
    init(
        froopId: String,
        froopName: String,
        froopType: Int,
        froopLocationid: Int,
        froopLocationtitle: String,
        froopLocationsubtitle: String,
        froopLocationCoordinate: CLLocationCoordinate2D,
        froopDate: Date,
        froopStartTime: Date,
        froopCreationTime: Date,
        froopDuration: Int,
        froopInvitedFriends: [String],
        froopImages: [String],
        froopDisplayImages: [String],
        froopThumbnailImages: [String],
        froopVideos: [String],
        froopVideoThumbnails: [String],
        froopIntroVideo: String,
        froopIntroVideoThumbnail: String,
        froopHost: String,
        froopHostPic: String,
        froopTimeZone: String,
        froopEndTime: Date,
        froopMessage: String,
        froopList: [String],
        template: Bool,
        hidden: [String],
        inviteUrl: String,
        videoSubscribed: Bool,
        guestApproveList: [String]
    ) {
        self.froopId = froopId
        self.froopName = froopName
        self.froopType = froopType
        self.froopLocationid = froopLocationid
        self.froopLocationtitle = froopLocationtitle
        self.froopLocationsubtitle = froopLocationsubtitle
        self.froopLocationCoordinate = froopLocationCoordinate
        self.froopDate = froopDate
        self.froopStartTime = froopStartTime
        self.froopCreationTime = froopCreationTime
        self.froopDuration = froopDuration
        self.froopInvitedFriends = froopInvitedFriends
        self.froopImages = froopImages
        self.froopDisplayImages = froopImages
        self.froopThumbnailImages = froopImages
        self.froopVideos = froopVideos
        self.froopVideoThumbnails = froopVideoThumbnails
        self.froopIntroVideo = froopIntroVideo
        self.froopIntroVideoThumbnail = froopIntroVideoThumbnail
        self.froopHost = froopHost
        self.froopHostPic = froopHostPic
        self.froopTimeZone = froopTimeZone
        self.froopEndTime = froopEndTime
        self.froopMessage = froopMessage
        self.froopList = froopList
        self.template = template
        self.hidden = hidden
        self.inviteUrl = inviteUrl
        self.videoSubscribed = videoSubscribed
        self.guestApproveList = guestApproveList
    }
    
    static func emptyFroop() -> Froop {
        
        return Froop(
            froopId: "",
            froopName: "",
            froopType: 0,
            froopLocationid: 0,
            froopLocationtitle: "",
            froopLocationsubtitle: "",
            froopLocationCoordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
            froopDate: Date(),
            froopStartTime: Date(),
            froopCreationTime: Date(),
            froopDuration: 0,
            froopInvitedFriends: [],
            froopImages: [],
            froopDisplayImages: [],
            froopThumbnailImages: [],
            froopVideos: [],
            froopVideoThumbnails: [],
            froopIntroVideo: "",
            froopIntroVideoThumbnail: "",
            froopHost: "",
            froopHostPic: "",
            froopTimeZone: "",
            froopEndTime: Date(),
            froopMessage: "",
            froopList: [],
            template: false,
            hidden: [],
            inviteUrl: "",
            videoSubscribed: false,
            guestApproveList: []
        )
    }
}

