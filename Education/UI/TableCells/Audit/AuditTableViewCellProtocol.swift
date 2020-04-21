//
//  AuditTableViewCellProtocol.swift
//  Education
//
//  Created by Andrey Medvedev on 19.02.2020.
//  Copyright © 2020 ООО Офис 365. All rights reserved.
//

import UIKit

protocol AuditTableViewCellProtocol where Self: UITableViewCell {
    func setup(with audit: Audit)
}

protocol AuditQuestionTableViewCellProtocol where Self: UITableViewCell {
    func setup(with auditQuestion: AuditQuestion)
}

protocol AuditAnswerTableViewCellProtocol where Self: UITableViewCell {
    func setup(answer auditAnswer: AuditAnswer?)
}

protocol AuditCommentTableViewCellProtocol where Self: UITableViewCell {
    func setup(with comment: Comment?)
}
