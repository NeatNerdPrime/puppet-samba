require 'spec_helper'

describe 'samba' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }

      describe 'samba::install' do
        describe 'should allow package ensure to be overridden' do
          let(:params) do
            {
              package_ensure: 'latest',
              package_manage: true,
            }
          end

          it {
            is_expected.to contain_package('samba').with_ensure('latest')
          }
        end

        describe 'should allow the package name to be overridden' do
          let(:params) do
            {
              packages: {
                server: ['samba-server'],
                client: [],
                utils: [],
              },
              package_manage: true,
            }
          end

          it {
            is_expected.to contain_package('samba-server').with_ensure('present')
          }
        end

        describe 'should allow the package to be unmanaged' do
          let(:params) do
            {
              package_manage: false,
            }
          end

          it {
            is_expected.not_to contain_package('samba')
          }
        end
      end

      describe 'samba::config' do
        let(:params) do
          {
            netbios_name: 'foo',
            additional_config: { server_multi_channel_support: 'yes',
                                 aio_read_size: 1,
                                 aio_write_size: 1,
                                 min_receivefile_size: 16_384 },
            idmap_config: { '*' => { backend: 'tbd', range: '400-999' },
                           'AD' => { unix_primary_group: 'Yes', unix_nss_info: 'Yes', schema_mode: 'rfc2307', range: '1000-2147483647', backend: 'ad' } }
          }
        end

        it {
          is_expected.to contain_samba__option('workgroup').with_value('WORKGROUP')
          is_expected.to contain_samba__option('server string').with_value('%h server (Samba Server Version %v)')
          is_expected.to contain_samba__option('netbios name').with_value('foo')
          is_expected.to contain_samba__option('domain master').with_value('auto')
          is_expected.to contain_samba__option('preferred master').with_value('auto')
          is_expected.to contain_samba__option('local master').with_value(true)
          is_expected.to contain_samba__option('os level').with_value(20)
          is_expected.to contain_samba__option('wins support').with_value(false)
          is_expected.to contain_samba__option('wins server').with_value(nil)
          is_expected.to contain_samba__option('name resolve order').with_value('lmhosts wins host bcast')
          is_expected.to contain_samba__option('server min protocol').with_value('SMB2_10')
          is_expected.to contain_samba__option('client max protocol').with_value('SMB3')
          is_expected.to contain_samba__option('client min protocol').with_value('SMB2_10')
          is_expected.to contain_samba__option('hosts allow').with_value([])
          is_expected.to contain_samba__option('hosts deny').with_value(['ALL'])
          is_expected.to contain_samba__option('interfaces').with_value([])
          is_expected.to contain_samba__option('bind interfaces only').with_value(false)
          is_expected.to contain_samba__option('security').with_value('auto')
          is_expected.to contain_samba__option('encrypt passwords').with_value(true)
          is_expected.to contain_samba__option('unix password sync').with_value(false)
          is_expected.to contain_samba__option('socket options').with_value('TCP_NODELAY')
          is_expected.to contain_samba__option('map to guest').with_value('Never')
          is_expected.to contain_samba__option('passdb backend').with_value('tdbsam')
          is_expected.to contain_samba__option('log file').with_value('/var/log/samba/log.%m')
          is_expected.to contain_samba__option('max log size').with_value(10_000)
          is_expected.to contain_samba__option('syslog').with_value(nil)
          is_expected.to contain_samba__option('ntlm auth').with_value(false)
          is_expected.to contain_samba__option('machine password timeout').with_value(604_800)
          is_expected.to contain_samba__option('realm').with_value(nil)
          is_expected.to contain_samba__option('kerberos method').with_value('default')
          is_expected.to contain_samba__option('dedicated keytab file').with_value(nil)
          is_expected.to contain_samba__option('obey pam restrictions').with_value(false)
          is_expected.to contain_samba__option('server multi channel support').with_value('yes')
          is_expected.to contain_samba__option('aio read size').with_value(1)
          is_expected.to contain_samba__option('aio write size').with_value(1)
          is_expected.to contain_samba__option('min receivefile size').with_value(16_384)
          is_expected.to contain_samba__option('idmap config * : backend').with_value('tbd')
          is_expected.to contain_samba__option('idmap config * : range').with_value('400-999')
          is_expected.to contain_samba__option('idmap config AD : unix_primary_group').with_value('Yes')
          is_expected.to contain_samba__option('idmap config AD : unix_nss_info').with_value('Yes')
          is_expected.to contain_samba__option('idmap config AD : schema_mode').with_value('rfc2307')
          is_expected.to contain_samba__option('idmap config AD : range').with_value('1000-2147483647')
          is_expected.to contain_samba__option('idmap config AD : backend').with_value('ad')
        }

        it {
          is_expected.to have_samba__option_resource_count(43)
        }
      end

      describe 'samba::service' do
        let(:params) do
          {
            service_manage: true,
            service_enable: true,
            service_ensure: 'running',
            service_name: ['smbd', 'nmbd'],
          }
        end

        it {
          is_expected.to contain_service('smbd').with(
            ensure: 'running',
            enable: true,
            name: 'smbd',
          )
        }
      end
    end
  end
end
