const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // const use_nettle = b.option(bool, "use_nettle", "") orelse false;
    // const enable_localhost_address = b.option(bool, "enable_localhost_address", "") orelse false;
    // const disable_consent_freshness = b.option(bool, "disable_consent_freshness", "") orelse false;
    // const enable_local_address_translation = b.option(bool, "enable_local_address_translation", "") orelse false;
    // const no_server = b.option(bool, "no_server", "") orelse false;
    const debug = b.option(bool, "sctp_debug", "") orelse false;
    const inet = b.option(bool, "sctp_inet", "") orelse true;
    const inet6 = b.option(bool, "sctp_inet6", "") orelse true;
    const invariants = b.option(bool, "sctp_invariants", "") orelse false;

    const upstream = b.dependency("usrsctp", .{});

    var usrsctp_flags = std.ArrayList([]const u8).init(b.allocator);

    // Setup flags
    {
        try usrsctp_flags.append("-D__Userspace__");
        try usrsctp_flags.append("-DSCTP_SIMPLE_ALLOCATOR");
        try usrsctp_flags.append("-DSCTP_PROCESS_LEVEL_LOCKS");

        if (invariants) {
            try usrsctp_flags.append("-DINVARIANTS");
        }

        if (debug) {
            try usrsctp_flags.append("-DSCTP_DEBUG");
        }

        if (inet) {
            try usrsctp_flags.append("-DINET");
        }

        if (inet6) {
            try usrsctp_flags.append("-DINET6");
        }

        if (target.result.os.tag == .linux) {
            try usrsctp_flags.append("-D_GNU_SOURCE");
        }

        if (target.result.os.tag == .windows and target.result.abi != .msvc) {
            try usrsctp_flags.append("-DSCTP_STDINT_INCLUDE=<stdint.h>");
        }

        // TODO (lukas): Do we need to define these condionally?
        //
        // try usrsctp_flags.append("-DHAVE_SYS_QUEUE_H");
        // try usrsctp_flags.append("-DHAVE_LINUX_IF_ADDR_H");
        // try usrsctp_flags.append("-DHAVE_LINUX_RTNETLINK_H");
        // try usrsctp_flags.append("-DHAVE_NETINET_IP_ICMP_H");
        // try usrsctp_flags.append("-DHAVE_NET_ROUTE_H");
        // try usrsctp_flags.append("-DHAVE_STDATOMIC_H");
        // try usrsctp_flags.append("-DHAVE_SA_LEN");
        // try usrsctp_flags.append("-DHAVE_SIN_LEN");
        // try usrsctp_flags.append("-DHAVE_SIN6_LEN");
        // try usrsctp_flags.append("-DHAVE_SCONN_LEN");
    }

    const usrsctp = b.addLibrary(.{
        .name = "usrsctp",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
        }),
    });

    usrsctp.addCSourceFiles(.{
        .files = usrsctp_sources,
        .flags = usrsctp_flags.items,
        .language = .c,
        .root = upstream.path("usrsctplib"),
    });
    usrsctp.addIncludePath(upstream.path("usrsctplib"));
    usrsctp.linkLibC();

    usrsctp.installHeader(upstream.path("usrsctplib/usrsctp.h"), "usrsctp.h");
    b.installArtifact(usrsctp);
}

const usrsctp_sources = &.{
    "netinet/sctp_asconf.c",
    "netinet/sctp_auth.c",
    "netinet/sctp_bsd_addr.c",
    "netinet/sctp_callout.c",
    "netinet/sctp_cc_functions.c",
    "netinet/sctp_crc32.c",
    "netinet/sctp_indata.c",
    "netinet/sctp_input.c",
    "netinet/sctp_output.c",
    "netinet/sctp_pcb.c",
    "netinet/sctp_peeloff.c",
    "netinet/sctp_sha1.c",
    "netinet/sctp_ss_functions.c",
    "netinet/sctp_sysctl.c",
    "netinet/sctp_timer.c",
    "netinet/sctp_userspace.c",
    "netinet/sctp_usrreq.c",
    "netinet/sctputil.c",
    "netinet6/sctp6_usrreq.c",
    "user_environment.c",
    "user_mbuf.c",
    "user_recv_thread.c",
    "user_socket.c",
};
