//
//  AuditDisplayHelper.swift
//  Education
//
//  Created by Andrey Medvedev on 20.02.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import UIKit

class AuditDisplayHelper {

    static func getStatusText(for audit: Audit?) -> String? {
        guard let viewerStatus = audit?.viewerStatus else {
            return nil
        }

        switch viewerStatus {
        case .new:
            return Localization.string("audit.status.new")
        case .toPass:
            return Localization.string("audit.status.pass")
        case .watched:
            return Localization.string("audit.status.watched")
        case .toCheck:
            return Localization.string("audit.status.check")
        case .onCheck:
            return Localization.string("audit.status.on_check")
        case .toModify:
            return Localization.string("audit.status.modify")
        case .onModify:
            return Localization.string("audit.status.on_modify")
        case .accepted:
            return Localization.string("audit.status.accepted")
        case .acceptedCommented:
            return Localization.string("audit.status.accepted_commented")
        case .failedTimeOut:
            return Localization.string("audit.status.failed_time_out")
        case .failedCommented:
            return Localization.string("audit.status.failed_commented")
        case .notDefined:
            return Localization.string("audit.status.not_defined")
        }
    }

    static func getStatusBackgroundColor(for audit: Audit?) -> UIColor {
        guard let viewerStatus = audit?.viewerStatus else {
            return UIColor.clear
        }

        switch viewerStatus {
        case .toPass, .toCheck:
            return AppStyle.Color.green
        case .toModify:
            return AppStyle.Color.orange
        default:
            return UIColor.clear
        }
    }

    static func getStatusTextColor(for audit: Audit?) -> UIColor {
        guard let viewerStatus = audit?.viewerStatus else {
            return AppStyle.Color.textMain
        }

        switch viewerStatus {
        case .toPass, .toCheck, .toModify:
            return AppStyle.Color.white
        default:
            return AppStyle.Color.textSelected
        }
    }
    
    static func getStatusQuestionTextColor(for audit: Audit?) -> UIColor {
        guard let viewerStatus = audit?.viewerStatus else {
            return AppStyle.Color.textSelected.withAlphaComponent(0.87)
        }

        switch viewerStatus {
            
        case .toCheck, .onCheck, .accepted, .acceptedCommented:
            return AppStyle.Color.green
        case .toModify, .onModify, .failedTimeOut, .failedCommented:
            return AppStyle.Color.red
        default:
            return AppStyle.Color.textSelected.withAlphaComponent(0.87)
        }
    }
    
    

    static func getStatusImage(for audit: Audit?) -> UIImage? {
        guard let viewerStatus = audit?.viewerStatus else {
            return nil
        }

        switch viewerStatus {
        case .new:
            return UIImage(named: "audit.state_icon.new")
        case .watched:
            return UIImage(named: "audit.state_icon.watched")
        case .onCheck:
            return UIImage(named: "audit.state_icon.on_check")
        case .onModify:
            return UIImage(named: "audit.state_icon.on_modify")
        case .accepted, .acceptedCommented:
            return UIImage(named: "audit.state_icon.accepted")
        case .failedTimeOut, .failedCommented:
            return UIImage(named: "audit.state_icon.failed")
        default:
            return nil
        }
    }

}
