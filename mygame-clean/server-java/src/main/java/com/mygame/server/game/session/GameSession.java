package com.mygame.server.game.session;

import com.mygame.server.game.avatar.AvatarState;

public class GameSession {
	private final String connectionId;
	private final String zone;
	private volatile AvatarState avatar;
	private volatile PendingWalk pendingWalk;
	private volatile String handItem = "0";
	private volatile String smiley = "visitor";
	private volatile String clothes = "[\"A_2\",\"B_2\",\"C_2\",\"8_9\",\"1_9\",\"4_9\",\"7_10\"]";
	private volatile String chatBalloon = "1";

	public GameSession(String connectionId, String zone, AvatarState avatar) {
		this.connectionId = connectionId;
		this.zone = zone;
		this.avatar = avatar;
	}

	public String connectionId() {
		return connectionId;
	}

	public String zone() {
		return zone;
	}

	public AvatarState avatar() {
		return avatar;
	}

	public void updateAvatar(AvatarState avatar) {
		this.avatar = avatar;
	}

	public PendingWalk pendingWalk() {
		return pendingWalk;
	}

	public void pendingWalk(PendingWalk pendingWalk) {
		this.pendingWalk = pendingWalk;
	}

	public String handItem() {
		return handItem;
	}

	public void handItem(String handItem) {
		this.handItem = handItem;
	}

	public String smiley() {
		return smiley;
	}

	public void smiley(String smiley) {
		this.smiley = smiley;
	}

	public String clothes() {
		return clothes;
	}

	public void clothes(String clothes) {
		this.clothes = clothes;
	}

	public String chatBalloon() {
		return chatBalloon;
	}

	public void chatBalloon(String chatBalloon) {
		this.chatBalloon = chatBalloon;
	}

	public record PendingWalk(int x, int y, boolean door, int requestRid) {
		public String position() {
			return x + "," + y;
		}
	}
}