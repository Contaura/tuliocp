#!/usr/bin/env bats

if [ "${PATH#*/usr/local/hestia/bin*}" = "$PATH" ]; then
    . /etc/profile.d/hestia.sh
fi

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'
load 'test_helper/bats-file/load'

function random() {
head /dev/urandom | tr -dc 0-9 | head -c$1
}

function setup() {
    # echo "# Setup_file" > &3
    if [ $BATS_TEST_NUMBER = 1 ]; then
        echo 'user=test-5285' > /tmp/hestia-test-env.sh
        echo 'user2=test-5286' >> /tmp/hestia-test-env.sh
        echo 'userbk=testbk-5285' >> /tmp/hestia-test-env.sh
        echo 'userpass1=test-5285' >> /tmp/hestia-test-env.sh
        echo 'userpass2=t3st-p4ssw0rd' >> /tmp/hestia-test-env.sh
        echo 'HESTIA=/usr/local/hestia' >> /tmp/hestia-test-env.sh
        echo 'domain=test-5285.tuliocp.com' >> /tmp/hestia-test-env.sh
        echo 'domainuk=test-5285.tuliocp.com.uk' >> /tmp/hestia-test-env.sh
        echo 'rootdomain=testtuliocp.com' >> /tmp/hestia-test-env.sh
        echo 'subdomain=cdn.testtuliocp.com' >> /tmp/hestia-test-env.sh
        echo 'database=test-5285_database' >> /tmp/hestia-test-env.sh
        echo 'dbuser=test-5285_dbuser' >> /tmp/hestia-test-env.sh
    fi

    source /tmp/hestia-test-env.sh
    source $TULIO/func/main.sh
    source $TULIO/conf/tulio.conf
    source $TULIO/func/ip.sh
}

@test "Setup Test domain" {
    run v-add-user $user $user $user@tuliocp.com default "Super Test"
    assert_success
    refute_output

    run v-add-web-domain $user 'testtuliocp.com'
    assert_success
    refute_output

    ssl=$(v-generate-ssl-cert "testtuliocp.com" "info@testtuliocp.com" US CA "Orange County" HestiaCP IT "mail.$domain" | tail -n1 | awk '{print $2}')
    mv $ssl/testtuliocp.com.crt /tmp/testtuliocp.com.crt
    mv $ssl/testtuliocp.com.key /tmp/testtuliocp.com.key

    # Use self signed certificates during last test
    run v-add-web-domain-ssl $user testtuliocp.com /tmp
    assert_success
    refute_output
}

@test "Web Config test" {
    for template in $(v-list-web-templates plain); do
        run v-change-web-domain-tpl $user testtuliocp.com $template
        assert_success
        refute_output
    done
}

@test "Proxy Config test" {
    if [ "$PROXY_SYSTEM" = "nginx" ]; then
        for template in $(v-list-proxy-templates plain); do
            run v-change-web-domain-proxy-tpl $user testtuliocp.com $template
            assert_success
            refute_output
        done
    else
        skip "Proxy not installed"
    fi
}

@test "Clean up" {
    run v-delete-user $user
    assert_success
    refute_output
}
