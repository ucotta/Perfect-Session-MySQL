//
//  SessionMySQL.swift
//  ElInstante
//
//  Created by Ubaldo Cotta on 20/10/16.
//
//

//
//  memorySession.swift
//
//  Created by Ubaldo Cotta on 20/10/16.
//
//  MemorySession.swift
//
//  This module create a session array and locks it every time that access to it.
//  Clean all expired cookies every minute, this action is launched when the minute changes
//  and a call to save, start or destroy happend


import Foundation
import PerfectHTTP
import PerfectLib
import MySQLConnectionPool

public class MySQLSession: SessionProtocol {
	public var cookieIDName: String
	public var tableName:String

	public var domain: String?
	public var expiration: PerfectHTTP.HTTPCookie.Expiration? = .relativeSeconds(60*30)
	public var path: String? = "/"
	public var secure: Bool? = true
	public var httpOnly: Bool? = true
	public var sameSite: PerfectHTTP.HTTPCookie.SameSite? = .strict

	public  init(cookieName cookieIDName: String = "perfectCookieSession", tableName:String) {
		self.cookieIDName = cookieIDName
		self.tableName = tableName

		if cookieIDName == "perfectCookieSession" {
			// Dont help intruders to identify your application, use custom session id.
			Log.warning(message: "MySQLSession started with cookieIdName = 'perfectCookieSession' use a custom one.")
		} else {
			Log.debug(message: "MySQLSession started with cookieIDName \(cookieIDName)")
		}
		//connector = SessionMySQLConnector(host: host, user: user, pass: pass, scheme: scheme, db: db)
	}

	public func setCookieSecureAttributes(secure: Bool?, httpOnly: Bool?, sameSite: PerfectHTTP.HTTPCookie.SameSite? ) {
		self.secure = secure ?? self.secure
		self.httpOnly = httpOnly ?? self.httpOnly
		self.sameSite = sameSite ?? self.sameSite

		checkSecurity(secure: secure, httpOnly: httpOnly, sameSite: sameSite)
	}
	public func start(_ request: HTTPRequest, response: HTTPResponse, expiration: PerfectHTTP.HTTPCookie.Expiration?) throws -> Session {
		var session:Session? = nil
		if let cookieID = request.cookie(key: cookieIDName) {
			session = try getCookieData(key: cookieID)
		}

		// if not was registered create a new one
		if session == nil {
			// Create a new session.
			session = Session(sessionManager: self, expiration: expiration ?? self.expiration!)
		}
		try deleteExpiredCookies()


		return session!
	}

	public func save(_ session: Session, response: HTTPResponse) throws {
		try updateCookieData(session: session)
		response.addCookie(createCookie(cookieID: session.getCookieID(), newExpiration: session.getNewExpireDate()))
		try deleteExpiredCookies()
	}

	public func destroy(_ response: HTTPResponse, cookieID: String) throws {
		try deleteCookie(cookieID: cookieID)
		try deleteExpiredCookies()
	}

	// MySQL functions
	public func getCookieData(key: String) throws -> Session? {
		// Dont catch connections errors.
		let conn = try MySQLConnectionPool.sharedInstance.getConnection()
		defer {
			conn.returnToPool()
		}

		do {
			if let row = try conn.queryRow("SELECT * FROM \(tableName) WHERE cookie = ? LIMIT 1", args: key) {
				return try Session.fromRow(sessionManager: self, row: row)
			}
		} catch {
			print("error in Session.fromRow")
		}

		return nil
	}

	private func updateCookieData(session: Session) throws {
		//try updateCookieData((session?.getCookieID())!, cookieData: (session?.toJSON())!, expireOn: (session?.getExpirationDate())!)

		// Dont catch connections errors.
		let conn = try MySQLConnectionPool.sharedInstance.getConnection()
		defer {
			conn.returnToPool()
		}

		do {
			try conn.execute("INSERT INTO \(tableName) (cookie, expire, data) VALUES (?, ?, ?) " +
				"ON DUPLICATE KEY UPDATE expire = values(expire), data = values(data)", args: session.getCookieID(), session.getExpirationDate(), session.toJSON())
		} catch {
			print("error in Session.fromRow")
		}
	}


	private func deleteCookie(cookieID: String) throws {
		let conn = try MySQLConnectionPool.sharedInstance.getConnection()
		defer {
			conn.returnToPool()
		}

		do {
			try conn.execute("DELETE FROM \(tableName) WHERE cookie = ? LIMIT 1", args: cookieID)
		} catch {
			print("error deleting cookie \(cookieID)")
		}
	}


	private func deleteExpiredCookies() throws {
		let conn = try MySQLConnectionPool.sharedInstance.getConnection()
		defer {
			conn.returnToPool()
		}

		do {
			try conn.execute("DELETE FROM \(tableName) WHERE expire < now()")
		} catch {
			print("error in deleting expired cookies.")
		}
	}
}



