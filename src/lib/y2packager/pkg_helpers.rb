# encoding: utf-8

# Copyright (c) [2018] SUSE LLC
#
# All Rights Reserved.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, contact SUSE LLC.
#
# To contact SUSE LLC about this file by physical or electronic mail, you may
# find current contact information at www.suse.com.

require "yast"
Yast.import "Pkg"
Yast.import "AddOnProduct"

module Y2Packager
  module PkgHelpers
    def self.repository_probe(url, pth)
      Yast::Pkg.RepositoryProbe(expand_url(url), pth)
    end

    def self.expand_url(url, alias_name: "", name: "")
      Yast::AddOnProduct.SetRepoUrlAlias(Yast::Pkg.ExpandedUrl(url), alias_name, name)
    end

    # Add a product from a URL
    #
    # @return [Integer,nil] Source ID for the registered repository; 
    def self.source_create(url, path = "", alias_name: nil, name: nil)
      alias_name ||= ""
      name ||= ""
      # Expanding URL in order to "translate" tags like $releasever
      expanded_url = expand_url(url, alias_name: alias_name, name: name)
      src_id = Yast::Pkg.SourceCreate(expanded_url, path)
      Yast::Pkg.SourceChangeUrl(src_id, url) if src_id && src_id != -1
      src_id
    end

    # Add a product from a URL
    #
    # @return [Integer,nil] Source ID for the registered repository; 
    def self.source_create_type(url, path, type, alias_name: nil, name: nil)
      alias_name ||= ""
      name ||= ""
      # Expanding URL in order to "translate" tags like $releasever
      expanded_url = expand_url(url, alias_name: alias_name, name: name)
      src_id = Yast::Pkg.SourceCreateType(expanded_url, path, type)
      Yast::Pkg.SourceChangeUrl(src_id, url) if src_id && src_id != -1
      src_id
    end

    def self.repository_add(repo)
      new_repo = Yast.deep_copy(repo)
      new_repo["base_urls"] = new_repo["base_urls"].map { |u| expand_url(u) }
      Yast::Pkg.RepositoryAdd(new_repo)
    end
  end
end
