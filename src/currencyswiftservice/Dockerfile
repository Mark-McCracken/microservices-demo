FROM swift:5.1.3 as builder
WORKDIR /root
COPY Package.* ./
RUN swift package resolve
COPY Sources Sources/
RUN swift build -c release --skip-update

FROM swift:5.1.3-slim
WORKDIR /root
COPY --from=builder /root .
CMD ["./.build/release/currencyswiftservice"]
