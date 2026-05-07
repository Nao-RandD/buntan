import SwiftUI

private struct LicenseEntry: Identifiable {
    let id = UUID()
    let name: String
    let license: String
    let body: String
}

private let apacheLicense = """
Licensed under the Apache License, Version 2.0 (the "License"); \
you may not use this file except in compliance with the License. \
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software \
distributed under the License is distributed on an "AS IS" BASIS, \
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. \
See the License for the specific language governing permissions and \
limitations under the License.
"""

private let bsd3License = """
Redistribution and use in source and binary forms, with or without \
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, \
this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, \
this list of conditions and the following disclaimer in the documentation \
and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors \
may be used to endorse or promote products derived from this software without \
specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" \
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE \
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE \
ARE DISCLAIMED.
"""

private let zlibLicense = """
This software is provided 'as-is', without any express or implied warranty. \
In no event will the authors be held liable for any damages arising from the \
use of this software.

Permission is granted to anyone to use this software for any purpose, \
including commercial applications, and to alter it and redistribute it freely, \
subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not claim \
that you wrote the original software.
2. Altered source versions must be plainly marked as such, and must not be \
misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.
"""

private let googleMeasurementLicense = """
Google App Measurement は Google LLC のサービス利用規約に基づいて提供されます。

https://policies.google.com/terms
"""

private let entries: [LicenseEntry] = [
    LicenseEntry(name: "Firebase iOS SDK",            license: "Apache 2.0",          body: apacheLicense),
    LicenseEntry(name: "Realm Swift",                 license: "Apache 2.0",          body: apacheLicense),
    LicenseEntry(name: "Realm Core",                  license: "Apache 2.0",          body: apacheLicense),
    LicenseEntry(name: "gRPC",                        license: "Apache 2.0",          body: apacheLicense),
    LicenseEntry(name: "Abseil",                      license: "Apache 2.0",          body: apacheLicense),
    LicenseEntry(name: "Google App Measurement",      license: "Google LLC 利用規約", body: googleMeasurementLicense),
    LicenseEntry(name: "GoogleDataTransport",         license: "Apache 2.0",          body: apacheLicense),
    LicenseEntry(name: "GoogleUtilities",             license: "Apache 2.0",          body: apacheLicense),
    LicenseEntry(name: "GTM Session Fetcher",         license: "Apache 2.0",          body: apacheLicense),
    LicenseEntry(name: "Interop iOS for Google SDKs", license: "Apache 2.0",          body: apacheLicense),
    LicenseEntry(name: "nanopb",                      license: "zlib",                body: zlibLicense),
    LicenseEntry(name: "LevelDB",                     license: "BSD 3-Clause",        body: bsd3License),
    LicenseEntry(name: "Promises",                    license: "Apache 2.0",          body: apacheLicense),
    LicenseEntry(name: "App Check",                   license: "Apache 2.0",          body: apacheLicense),
]

struct LicenseView: View {
    var body: some View {
        List(entries) { entry in
            NavigationLink {
                ScrollView {
                    Text(entry.body)
                        .font(.caption)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .navigationTitle(entry.name)
                .navigationBarTitleDisplayMode(.inline)
            } label: {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.name)
                    Text(entry.license)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("ライセンス")
    }
}
