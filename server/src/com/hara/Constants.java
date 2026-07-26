package com.hara;

/**
 * Cross-cutting string constants shared between modules where coupling
 * through a service would be overkill. Per user convention: small immutable
 * facts that several layers need to agree on live here, not in any one
 * service.
 */
public final class Constants {

    private Constants() {}

    /**
     * Guest username prefix — must match three things in lock-step:
     * <ul>
     *   <li>SFS zone config: {@code <guestUserNamePrefix>Guest#</guestUserNamePrefix>}</li>
     *   <li>Client-side {@code AvatarCreatePanel.initForm} BaseCloth-branch
     *       check ({@code avatarName == "Guest#" + avatarId})</li>
     *   <li>Server-side {@code InitResponsePresenter.needsBaseCloth()}
     *       placeholder name projection</li>
     * </ul>
     */
    public static final String GUEST_NAME_PREFIX = "Guest#";
}
